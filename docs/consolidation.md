# Consolidation — three tools → one, and why a warehouse next to the CRM

The engine didn't start on a clean stack. It started on **Instantly** (email sequences) + **HeyReach** (LinkedIn automation) + **Clay** (enrichment), wired together by hand, next to a CRM. This doc covers the consolidation onto **lemlist + a Postgres warehouse, operated by n8n** — and the landmines that made it more than an invoice exercise.

## Why consolidate — the invoice was the smallest reason

~€800/mo → **~€260/mo** (three multichannel seats). Nice, but the real costs were structural:

- **Three data models.** A contact existed in Instantly, HeyReach, and Clay with three IDs, three states, and no shared suppression. "Did we already touch this person?" was un-answerable without joining three exports by hand.
- **Three webhook surfaces** to keep alive, each with its own auth quirks and silence modes.
- **Split channels = split sequences.** Email in one tool and LinkedIn in another means the *sequence* — the thing that's supposed to coordinate channels — lives in neither. lemlist is natively multichannel: one sequence owns the email step, the LinkedIn step, and the stop-conditions across both.
- **Enrichment trapped in a UI.** Clay's seat pricing and table-centric model made every enrichment a manual workflow. Replaced short-term by lemlist's native enrichment, and structurally by **Deepline** — code-first enrichment plays that run from the terminal and pay per execution (typically **under €80/mo**, capped at €200, against Clay's ~€350 seat) — with results landing directly in the warehouse instead of a browser tab.

## The three landmines

The migration plan spent more words on what could go wrong than on the happy path. All three earned it.

### 1 · Warmup traffic + a CRM auto-logger = a flood

The CRM auto-created a lead from every email BCC'd to its capture address — and a blanket mail rule BCC'd **all** outbound, including warmup traffic. The day warmup ramped, the CRM gained **~10,000 junk records in one flood**; cleanup ran for weeks and warmup stayed off across all 41 mailboxes until the mail rule was fixed.

The migration rule that came out of it: **fix the mail-rule exclusion before enabling warmup in the new tool** — warmup messages carry a stable subject tag, so the exclusion is one deterministic condition. The same incident is why the reply engine ([sibling repo](https://github.com/Miksh21/agentic-reply-engine)) filters warmup traffic *before* classification: warmup mail is engineered to look like real correspondence, which means every naive listener downstream will believe it.

### 2 · Cutover must be per-mailbox and atomic

A mailbox live in both sequencers at once double-sends — the fastest route to spam folders that exists. So there is no big-bang: each mailbox is disconnected from the old tool and connected to the new one as a single atomic step, while real campaigns keep sending throughout — **sender reputation is maintained by real sends, not by which tool sends them.**

### 3 · The platform's limits fixed the sprawl

The old stack had accumulated **10 inboxes per sender** — Instantly-era volume-spreading, plus 18 dead lookalike-domain mailboxes from an agency experiment. lemlist's plan caps senders at **5 inboxes per seat**, which forced the question the team had been avoiding: *which five are actually the best-warmed?* The cap turned an open-ended cleanup debate into a ranking exercise. Sometimes the constraint is the consultant.

### Bonus discovery: OAuth-only mailbox connects

The tenant had basic auth disabled (as every Microsoft 365 tenant now should) — which surfaced late as: sequencer mailbox connections **cannot be automated via API** (the API path requires IMAP/SMTP credentials that no longer exist). Every keeper mailbox connects through the OAuth flow in the UI, by hand. The lesson generalizes: *cutover labor estimates must be verified against the auth reality of the tenant, not the API docs.*

## The phased cutover

```
0  Prune        — keep/drop decision per mailbox (23 live keepers / 18 dead dropped)
1  Verify caps  — plan limits vs. keeper count BEFORE committing (found the 5/seat cap)
2  Mail rules   — the warmup exclusion, before any warmup
3  Senders      — OAuth reconnects + LinkedIn identities
4  Campaigns    — rebuild only the LIVE campaigns (2 of 49 + 37 were worth moving —
                  the rest were paused, finished, or test junk; migration is a
                  chance to NOT move debt)
5  Data + CRM   — leads in, reply/status write-back wired through the warehouse
6  Cutover      — per-mailbox atomic switches; offboard the old tools last
```

Step 4 deserves its own emphasis: of 86 campaigns across the two old tools, **two** were alive and worth rebuilding. Consolidation is the cheapest moment you will ever get to leave dead weight behind.

---

# One warehouse, many mirrors — why an SSOT next to the CRM

The CRM was never the problem — it's the system of record for **deals and customers**, and it stays that. The problem is that a CRM is the wrong *shape* for outbound execution:

- **No contact-level execution fields.** Czech outbound needs vocative name forms, gender (for verb agreement in copy), and language per contact — enrichment the CRM has no columns for and no business storing.
- **The contact layer was hollow.** ~80% of potential-tier accounts had **no contact person on file at all.** A signal with no person to land on routes nowhere — the enrichment gap *was* part of the lead-supply bottleneck.
- **Side-effectful automation.** The auto-lead-from-BCC behavior that caused the flood is a feature for a sales team and a hazard for a machine. You don't want your execution layer writing to a system that reacts.
- **No cross-tool memory.** Suppression and touch history spanning Instantly, HeyReach, and lemlist can't live in any one of them.

So the warehouse (**Supabase/Postgres**) holds the execution truth — roughly 80k contacts, morphology-enriched, with three load-bearing structures ([schema excerpt](../examples/contact_360.sql)):

- **`touches`** — one row per send / open / reply / connect, *from any tool, ever*. The old tools' history was harvested in before they were switched off, so "when did anyone last touch this person, through anything" is one indexed query.
- **`suppression`** — with a `reason` per row (replied / bounced / unsubscribed / customer / open-deal / blocklist), because "why can't I contact them" matters as much as "can I".
- **`contact_360`** — one view answering the operator's question: who is this, what language and form of address, are they a customer, is there an open deal, when were they last touched and by which campaign, and what's their subscriber status. Every automation reads this view; none of them re-derives it.

The sync is **one-way by design**: the warehouse computes, the tools mirror (contacts and personalization flow *to* the sequencer as custom fields; events flow *back* as touches). No enrichment, no scoring, no state lives in a tool — which is what made swapping the tools possible at all. Consolidation onto lemlist took a migration script, not a re-architecture, because there was nothing in Instantly worth keeping except history — and the history was already home.

One write-back detail that earns its keep: activities the machine writes back to the CRM carry a **🤖 marker prefix**, and the human-touch suppression rule *excludes* marked activities — otherwise the system would read its own write-backs as "a human touched this account recently" and suppress itself into silence. See [decisions.md](decisions.md).
