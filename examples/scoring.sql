-- Representative scoring model — the weight × decay × stacking logic that lives
-- IN the warehouse as functions/views. Schema is illustrative, not a live schema.
-- No real data. See docs/signal-model.md for the reasoning.

-- ── time-decay: a signal is worth most the moment it lands ──────────────────
create or replace function signal_decay(ts timestamptz) returns numeric as $$
  select case
    when ts > now() - interval '24 hours' then 1.5
    when ts > now() - interval '7 days'   then 1.2
    when ts > now() - interval '14 days'  then 1.0
    when ts > now() - interval '30 days'  then 0.7
    else 0.3
  end;
$$ language sql stable;

-- ── per-account, per-type scoring with the stacking cap ────────────────────
-- The cap (weight * 1.5) is what forces HOT to require ≥2 independent signal
-- types — the anti-false-alarm mechanism.
create or replace view account_scores as
with per_type as (
  select s.account_id,
         s.signal_type,
         least( sum(w.weight * signal_decay(s.observed_at)),
                max(w.weight) * 1.5 )                       as type_score
  from signals s
  join signal_weights w using (signal_type)
  where s.observed_at > now() - interval '60 days'
  group by s.account_id, s.signal_type
),
trigger_score as (
  select account_id, sum(type_score) as trigger_score,
         count(*) as distinct_signal_types
  from per_type group by account_id
)
select a.id as account_id,
       -- past-client base never decays: the durable floor
       (case when a.is_past_client then 60 else 0 end)
         + coalesce(t.trigger_score, 0)                     as score,
       coalesce(t.distinct_signal_types, 0)                 as signal_types,
       -- suppression gate: deterministic booleans first
       (a.has_open_deal or a.recent_human_touch
        or a.do_not_contact or a.recent_outbound_touch)     as suppressed
from accounts a
left join trigger_score t on t.account_id = a.id;

-- ── heat tiers + the routing decision ──────────────────────────────────────
create or replace view account_heat as
select account_id, score, signal_types,
  case
    when suppressed                    then 'SUPPRESSED'  -- never contacted
    when score >= 100                  then 'HOT'         -- → a human, today
    when score >= 50                   then 'WARM'        -- → nurture / wait
    else                                    'COOL'        -- → accumulate
  end as heat
from account_scores;
