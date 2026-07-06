# Alpha Signals — the originality test

The signal-tool market sells the same triggers to everyone: "hiring," funding rounds, tech installs, intent topics. Useful — but if your competitor can buy the exact same signal off the shelf, so can everyone else, and the accounts on the receiving end are already fatigued by the time you arrive.

So every signal in this engine passes one test first:

> **Can a competitor buy this exact signal off the shelf?**
> If yes → table stakes. Usable, but never the spine of the motion.
> If no → *alpha*. First-party, un-buyable, compounding. Build the motion on these.

## The two alpha signals

| Signal | Reply rate | Source | Decay profile |
|---|---|---|---|
| **Past-placement / ex-employer** — the buyer sits at a company you already delivered for | **16.9%** | own CRM won-deal history | **slow & durable** — earned trust persists for years |
| **Active job posting** — the buyer is publicly advertising a need you fill | **15.9%** | scrape → LLM extract → domain resolve | **fast** — ×0.3 by day 30; the role gets filled |

Neither exists in any vendor's catalog. The first is manufactured by the business's own delivery history; the second is public but only *becomes* a signal through the extraction pipeline that resolves it to an in-market account and lands it on a warm base.

## The evidence — what converts and what doesn't

All from the same operation, same market, same senders:

| Signal-led ✅ | Reply | Volume-led ❌ | Reply |
|---|---|---|---|
| Past-placement base | **16.9%** | Mass CRM blast | 2.63% |
| Active job posting | **15.9%** | Bought "hiring" trigger, *not used in the copy* | **0.17%** |
| Signal-led campaigns overall | 12–17% | | |

Two lessons hiding in that right-hand column:

1. **A bought signal without fit is worse than no signal** — the 0.17% campaign had a "trigger," but the wrong market and no leverage.
2. **A signal not used as the spine of the message is worthless.** The trigger has to be *in the copy* — the reason-you're-writing, not a hidden filter. Signal-as-filter converts like cold, because to the reader it *is* cold.

## Decay is per-signal, not global

The [scoring model](signal-model.md) applies decay multipliers — but the deeper point is that **different signal types melt at different rates**, and the model has to encode that:

- A **job posting** is a time-boxed need. Half its value is gone in a week; by day 30 the role is filled or frozen. Speed is the whole game.
- A **past placement** is a relationship. It doesn't expire on a timer — which is why it enters the score as the *base term* that never decays, not as a decaying event.
- A **website visit** is in between: high intent, fast fade.

This is why the durable signal and the fast signals play different roles in the stack: the base decides *who is warm*; the triggers decide *why now*.

## The stacking architecture

The alpha pair is complementary by construction — one durable base, one fast trigger:

```
TAM spine (the CRM's mapped market)
   + DURABLE BASE   : past-placement / customer history  → account standing-warm
   + FAST TRIGGERS  : job posting · website visit · news/expansion
        ↓  signals table → decay + stack scoring view
   FIRE only on: a fast trigger landing on a warm base — or ≥ 2 stacked triggers.
   A single cool trigger → HOLD and accumulate. Don't burn the account.
        ↓
   HOT → human task, signal IN the copy
```

## The flywheel — why alpha compounds and bought signals fatigue

```
   Mapped TAM
      ↓
   Owned first-party signals ──► stacked warm outreach ──► more delivered work
   (placements · job posts        (16.9% / 15.9%,               ↓
    · site visits)                 signal in the copy)    more placement history
      ▲                                                         ↓
      └────────── the past-placement base grows with every win ─┘
```

Every delivered engagement **enlarges the durable base** — the moat widens with use. Bought intent data does the opposite: the more customers a signal vendor has, the more fatigued its signals get. One asset appreciates, the other depreciates, and they cost about the same to activate.

That asymmetry is the entire strategic argument of this repo. The scoring math, the gate, the warehouse — all of it exists to *activate* an asset the business already owned and nobody was using.
