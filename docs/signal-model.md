# The signal model

The whole system is one idea: **not every signal is worth the same, and none are worth the same forever.**

## Weights

Each signal type carries a base weight — how much intent it implies. Representative values:

| Signal | Weight | Why |
|---|---|---|
| Website visit (de-anon) | 50 | active, unprompted interest |
| Live job posting | 40 | a concrete, time-boxed need |
| Own-content engagement | 30 | attention, not yet intent |
| Company news / funding | 15–20 | context, weak on its own |
| **Past-client base** | **+60**, no decay | a prior relationship — the moat |

## Decay

A signal is worth most the moment it happens and fades from there. A multiplier on the timestamp:

```
1.5×   < 24h      (strike while hot)
1.2×   < 7 days
1.0×   < 2 weeks
0.7×   < 30 days
0.3×   older      (basically archived)
```

The one exception is the **past-client base**: a relationship you've already earned doesn't decay. That's what makes it the durable floor under everything else.

## Stacking + the per-type cap

Scores sum across signal types — but each type is **capped** (roughly `weight × 1.5`). That cap is deliberate:

```
score = base + Σ_type  min( Σ weight × decay , cap_type )
```

Because one type can't run away, reaching the HOT threshold structurally requires **two independent kinds of evidence.** A company that visited the site *and* posted a relevant job is HOT. A company that only tripped one noisy signal ten times is not. This is the anti-false-alarm mechanism — it's what lets you point a human at HOT accounts and trust it.

## Heat tiers

```
HOT   ≥ 100   → a human, same morning
WARM  ≥ 50    → nurture / wait for a second signal
COOL  < 50    → accumulate context
```

A weak lone signal lands in COOL/WARM and simply waits. If a second signal stacks before it decays, it graduates. If not, it fades. **A threshold, not a timer** — the system never "acts because time passed," only because evidence crossed a line.

## The gate — deterministic first, AI last

Before anything reaches a person, a suppression gate runs. It's ~90% boolean:

- **open deal** in the CRM → leave it alone (a rep owns it)
- **human touched them in the last 60 days** → don't double-touch
- **do-not-contact / unsubscribed** → never
- **14-day cross-channel cooldown** (from our own prior outreach) → space it out

These are database facts — instant, free, identical every run, and auditable ("suppressed: open deal #4471"). An LLM is invoked for exactly one thing a boolean can't do: scanning a free-text CRM note for a buried human instruction like *"nezavolejte jim"* ("don't call them"). See [`../examples/gate.py`](../examples/gate.py).

## The one number that matters

Cold outreach converts in the low single digits. A single relevant signal lifts it into the high teens. Stacked signals — the right account, warm, at the right moment — is a different game entirely. The engine exists to manufacture that third case on purpose, at scale, without burning the people on the other end.
