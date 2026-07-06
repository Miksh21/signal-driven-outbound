# Shipped — and where it goes next

## Running

- **The warehouse** — companies, deals, ~80k morphology-enriched contacts, cross-tool touch history, reasoned suppression ([schema excerpt](../examples/contact_360.sql)); nightly CRM refresh keeps the mirror fresh.
- **Decay + stacking scoring** — live as warehouse views (`v_account_signal_scores` and friends): per-type decay, per-type caps, heat tiers with suppression baked into the view itself, so no consumer can accidentally read an un-gated score.
- **Signal capture** — website-visitor poller publishing into the signals table; job-posting pipeline (scrape → LLM extract → domain resolve → dedupe); the past-placement base derived from CRM won-deal history.
- **The gate, v2** — live-tested against the real CRM and upgraded from a boolean list to a 3-tier verdict: **GREEN** (all-clean → enroll + auto-launch + CRM write-back + cooldown ledger entry), **AMBIGUOUS** (enroll-but-**pause** + an AI adjudicator summarizes the conflict into a one-click human review task), **BLOCK** (mark processed, touch nothing). Write-backs carry the 🤖 marker so the gate can't suppress on the machine's own activity ([decisions.md](decisions.md) №6).
- **The distributor** — signals → gate → tiered enrollment with the signal materialized into the copy, CRM task write-back, 14-day cross-channel cooldown ledger.
- **Localized copy** — vocative forms and speaker-gender agreement enriched warehouse-wide via a morphology service (never regex), read by copy at render time.
- **One sequencer** — three execution tools consolidated into a single multichannel platform, with cross-tool history harvested into the warehouse first ([consolidation.md](consolidation.md)).
- **The reply side** — everything that happens after a prospect answers: 12 routes, a message ledger, a weekly learning loop. Documented in its own repo: **[agentic-reply-engine](https://github.com/Miksh21/agentic-reply-engine)**.

## Where it goes next

Expansion, in priority order — each one widens the capture side, which is where the leverage is:

- **Open-data vacancy ingest** — the national employment register publishes vacancies as structured open data, keyed by company ID. Wiring it in makes the cleanest possible source the primary one and retires the paid-scraper dependency.
- **Net-new auto-tiering** — a company that fires a signal but isn't in the market map gets resolved automatically: register lookup → industry code → tier. The lookup exists; the last mile is making it hands-free.
- **Contact-layer depth** — filling the contact gap on potential-tier accounts, so every captured signal has a person to land on. Signals are columns; contacts are the rows they need.
- **Proof-bank templating** — moving delivery track-record numbers into the warehouse so copy can cite them per-segment, automatically.
- **Outcome-driven reweighting at scale** — the learning loop re-derives signal weights from what actually books meetings; its resolution keeps improving as outcome volume compounds.
- **Competitive-posture layer** — designed and validated on public data, **deliberately parked pending legal sign-off** (see [decisions.md](decisions.md)). It ships when counsel clears it, not before.

## Why this list exists

The gaps *are* the plan — each item is a scoped next step with a known design, not a vague aspiration. A roadmap you can point at beats a demo that hides its seams.
