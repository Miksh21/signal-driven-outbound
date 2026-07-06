# Seven decisions I'm proud of

Building fast is easy. These are the calls that made the system *good* — and most of them were about choosing restraint.

## 1 · Open data beats scraping

The obvious way to map a market is to scrape job boards. I didn't. A government business register publishes the same universe as **open data**, keyed by company registration ID.

That one choice solved three problems simultaneously: it's **legal** (no terms-of-service or database-right exposure), it's **free**, and — because every record carries the registration ID — it matches to the CRM and the market map **deterministically**, not by fuzzy company-name guessing that fails ~90% of the time. When a clean, boring, authoritative source exists, use it.

## 2 · Don't AI a boolean

"Does this account have an open deal?" is a database question. "Was there a human touch in the last 60 days?" is a database question. Running a language model to answer them would be slower, cost money per call, be non-deterministic, and — worst — could *hallucinate a wrong answer to a question the data already knows for certain.*

So the gate is deterministic SQL. The LLM is reserved for the one job only it can do: reading a free-text note for a human intention no column captures. The rule extends everywhere: **use the cheapest tool that gives a correct, auditable answer, and save the expensive, fuzzy one for genuinely fuzzy problems.**

## 3 · Legal-first, then build

The most tempting feature was competitor-displacement: detect that a company already uses a rival, and pitch against them. Powerful — and a minefield.

Before writing a line, I read the relevant unfair-competition statutes (comparative advertising, disparagement, trade-secret law). The conclusions changed the design: **source everything from public data** (never a leaked document), and **critique the *method*, not the named competitor** — which sidesteps the disparagement and trade-secret risks entirely. Then I **parked the whole feature pending a lawyer's sign-off**, and shipped everything around it. Speed that creates liability isn't speed.

## 4 · Spend human attention like it's expensive — because it is

The decay-and-stacking math has one job: make sure a person is only ever pointed at an account where *two independent signals corroborate each other.* A single stray event never reaches a human. This is the difference between "an alert system people learn to ignore" and "a queue people trust." The scarcest resource sets the design constraint.

## 5 · The data model owns the logic

Scoring, gating, and health metrics live **in the warehouse** as views and functions — not inside any tool. The tools (CRM, sequencer, workflow engine) are interchangeable front-ends that read those views. This is the opposite of the usual "logic trapped inside a SaaS" trap: the intelligence is portable, the vendors are disposable, and the data stays consistent because there's exactly one place it's computed.

## 6 · Tag the machine's own footprints

The gate suppresses any account a human touched in the last 60 days — correct, and a trap. The engine *also* writes activities back to the CRM on every automated touch (so reps see the full history). Untagged, those write-backs look exactly like human touches to the gate — and the system reads its own footprints as "a rep owns this," suppressing itself into silence, account by account, until nothing sends and nothing errors.

The fix is one convention: every machine-written activity carries a **🤖 marker prefix**, and the human-touch query excludes marked rows. Trivial to implement, invisible until you need it — and the class of bug it prevents (a feedback loop reading its own output as input) is one of the defining failure modes of agentic systems. If your automation writes to a system it also reads, **the write must be distinguishable from the world.**

## 7 · Let the platform's limits fix your sprawl

During the [sequencer consolidation](consolidation.md), the new platform capped sending inboxes at 5 per seat. The old stack had drifted to **10 inboxes per sender** — volume-spreading from the blast era — plus 18 dead mailboxes on lookalike domains. The instinct is to fight the cap (upgrade the plan, split seats). The better move was to treat it as a free consultant: rank each sender's inboxes by warmup health, keep the best five, drop the rest.

The cap converted an open-ended cleanup debate ("which of these do we *really* need?") into a mechanical ranking exercise with a deadline. Constraints from outside are sometimes the only thing that gets accumulated debt actually deleted — the same reason the migration rebuilt only the **2 live campaigns out of 86** and left the dead weight in the old tools.

---

**The throughline:** every one of these is a *restraint* — a cheaper tool, a public source, a parked feature, a higher bar before acting. Anyone can wire APIs together. Knowing which wire *not* to connect is the actual skill.
