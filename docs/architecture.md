# Architecture

Five layers, one rule: **the warehouse is the only source of truth; everything else is a replaceable front-end.**

## 1 · Signal sources

Signals come in from wherever intent leaks. The valuable ones are **first-party** — things a competitor can't buy:

- **Website de-anonymization** — anonymous visitor resolved to a company.
- **Own-content engagement** — who reacts to the team's posts (a soft, early signal).
- **Live hiring posts** — scraped, passed through an LLM to extract *{company, role, location}*, then resolved to a domain via neural search.
- **National-register open data** — a government vacancy/company feed, keyed by company registration ID. Legal, structured, and it matches deterministically (no fuzzy names).
- **Past-client base** — every prior engagement, loaded once. The durable warm floor.

## 2 · Warehouse (single source of truth)

One Postgres database holds accounts, contacts, the validated market (built from national registers, tiered by industry code), and the signals ledger (deduplicated so the same event never counts twice).

The important design choice: **the logic lives here, as views and functions**, not scattered across tools. `account_scores`, `warm_base`, `signal_health` are just views — the automations read them like an API. Swap the sequencer or the CRM tomorrow and the brain doesn't move.

## 3 · Scoring brain

The decision layer. Turns raw signals into `weight × decay × stacking` scores, applies the suppression gate, and emits a heat tier per account. It answers two questions the old system never asked: **who, and when.** (Details: [signal-model.md](signal-model.md).)

## 4 · Routing — two lanes

The core insight is that not every qualified account deserves the same *resource*:

- **Cold lane → machine.** A single clean signal is enough. The account's role maps to a tier (T1/T2/T3), which picks a sequence; a pre-enrollment gate re-checks suppression; a research step attaches a specific, true icebreaker. Ambiguous cases enroll-but-pause and raise a human review task instead of guessing.
- **Hot lane → human.** A stacked account is scarce and valuable, so it goes to a person — the best-matched contact, gated just-in-time, delivered as a task *with the signal and the why-now* before the workday starts.

Human attention is the scarcest resource in the system, so the whole design is about spending it only where signals have already corroborated each other.

## 5 · Execution & feedback

- **Sequencer** — tiered email + LinkedIn, with localized, grammatically-correct copy generated per contact.
- **CRM write-back** — every automated touch is logged back to the CRM, which *feeds the 60-day gate* — the loop that stops the system colliding with a live human sales effort.
- **Cooldown ledger** — guarantees no account is hit twice across channels inside the window.
- **Feedback loop (planned)** — reweight signal values from actual closes, so the model sharpens itself.

## Where it runs

Orchestration runs on a cloud workflow engine, 24/7 — deliberately *not* on anyone's laptop, so the pipeline survives a closed lid. The warehouse holds state; the workflows hold schedule and glue. Nothing critical is local.
