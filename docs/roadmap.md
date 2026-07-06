# What's honestly unfinished

A system is never "done," and pretending otherwise is a tell. Here are the real edges, on both ends of the pipeline.

## Shipped since this list was first written

Keeping the crossed-off items visible on purpose — a roadmap that only ever grows is as suspicious as one that's always empty.

- ~~Decay + stacking scoring~~ — **live** as warehouse views (`v_account_signal_scores`, heat tiers with suppression baked in).
- ~~Website-visitor signal~~ — **live**: poller publishing into the signals table.
- ~~Gate~~ — **live-tested against the real CRM**, and upgraded from a boolean list to a 3-tier verdict: GREEN (all-clean → enroll + auto-launch + write-back), AMBIGUOUS (enroll-but-**pause** + an AI adjudicator summarizes the conflict into a human review task), BLOCK (mark processed, touch nothing). The write-backs carry the 🤖 marker so the gate can't suppress on the machine's own activity ([decisions.md](decisions.md) №6).
- ~~Localized grammar~~ — vocative forms and gender now enriched warehouse-wide via a morphology service (never regex), read by copy at render time.
- ~~Tool sprawl~~ — three execution tools consolidated into one multichannel sequencer; cross-tool touch history harvested into the warehouse first ([consolidation.md](consolidation.md)).
- ~~Feedback loop (design)~~ — the reply side and the outcome-driven reweighting loop are now **designed end-to-end** in the sibling repo, [agentic-reply-engine](https://github.com/Miksh21/agentic-reply-engine): 12 reply routes, a message ledger, and a weekly learning job that re-derives signal weights from what actually booked meetings.

## Upstream — capture / supply

The capture side is where the leverage is, and where the most work remains.

- **Open-data vacancy ingest** — designed, not yet wired. This is the biggest, cleanest source: legal, structured, keyed by company ID, and heavily weighted toward the target segment. When it's live it becomes the primary signal, and it removes the current dependency on a paid scraper.
- **Net-new tiering** — a company that appears in a signal but isn't in the market map needs to be resolved (registration lookup → industry code → tier) automatically. The lookup works; the automation isn't built.
- **Contact-layer enrichment** — the market map has the *accounts*, but a large share of potential-tier accounts have no contact person on file. A signal with nobody to land on routes nowhere; closing this gap is part of the capture fix, not a nice-to-have.
- **Proof-bank** — the track-record numbers that would make outreach sharper still live in a spreadsheet. They need to move into the warehouse before they can be templated into copy.
- **Competitive-posture layer** — designed and validated against public data, but **parked pending legal sign-off** (see [decisions.md](decisions.md)). It stays parked until counsel clears it.

## Downstream — decision / close

- **Cold lane held** — the tiered sequences and the 3-tier gate are built and live-tested end-to-end, but held inactive until the capture side produces enough clean signal to feed them. No point activating a machine with nothing to eat.
- **Reply engine (build)** — designed in the sibling repo; the build runs ledger-first (useful from day one) with the learning loop last, since it needs ~4–6 weeks of decisions + outcomes before its numbers mean anything.
- **Feedback loop (data)** — the design exists; the weights are still hand-set until ~30–50 real outcomes accumulate. Hand-tuned is honest at this sample size.
- **CRM consolidation** — a de-duplication and brand-grouping pass is generated (merge lists, owner-conflict lists), but the owner-assignment decisions are a human call and await review. Automating the *analysis* is fine; automating the *politics* is not.
- **Deliverability handshake** — an external email-verification step should write status back to the sequencer so only deliverable addresses send. Not yet wired.

## Why this list exists

Two reasons. First, it's true. Second, the gaps *are* the plan — each one is a scoped next step, not a vague aspiration. A roadmap you can point at beats a demo that hides its seams.
