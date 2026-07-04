# What's honestly unfinished

A system is never "done," and pretending otherwise is a tell. Here are the real edges, on both ends of the pipeline.

## Upstream — capture / supply

The capture side is where the leverage is, and where the most work remains.

- **Open-data vacancy ingest** — designed, not yet wired. This is the biggest, cleanest source: legal, structured, keyed by company ID, and heavily weighted toward the target segment. When it's live it becomes the primary signal, and it removes the current dependency on a paid scraper.
- **Net-new tiering** — a company that appears in a signal but isn't in the market map needs to be resolved (registration lookup → industry code → tier) automatically. The lookup works; the automation isn't built.
- **Proof-bank** — the track-record numbers that would make outreach sharper still live in a spreadsheet. They need to move into the warehouse before they can be templated into copy.
- **Competitive-posture layer** — designed and validated against public data, but **parked pending legal sign-off** (see [decisions.md](decisions.md)). It stays parked until counsel clears it.

## Downstream — decision / close

The decision side is further along, but not finished.

- **Cold lane inactive** — the tiered sequences are built and tested end-to-end, but held off until the capture side is producing enough clean signal to feed them. No point activating a machine with nothing to eat.
- **Localized grammar** — the copy engine declines names and roles into the correct grammatical case (a real requirement in Czech). It needs one configuration pass and a spot-check against a language model that occasionally slips on rare forms.
- **Feedback loop** — the model's weights are hand-set. They should be re-derived from actual closes — but that needs ~30–50 outcomes before the numbers mean anything. Until then, hand-tuned is honest.
- **CRM consolidation** — a de-duplication and brand-grouping pass is generated (merge lists, owner-conflict lists), but the owner-assignment decisions are a human call and await review. Automating the *analysis* is fine; automating the *politics* is not.
- **Deliverability handshake** — an external email-verification step should write status back to the sequencer so only deliverable addresses send. Not yet wired.

## Why this list exists

Two reasons. First, it's true. Second, the gaps *are* the plan — each one is a scoped next step, not a vague aspiration. A roadmap you can point at beats a demo that hides its seams.
