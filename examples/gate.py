"""
Representative suppression gate. The rule that makes the whole system safe to
point at a human: check the cheap, certain, deterministic facts first — and use
an LLM for the ONE thing a boolean can't express.

Illustrative; no real deployment or data.
"""
import os, json, urllib.request

LLM_KEY = os.environ["LLM_API_KEY"]


def gate(account: dict, recent_notes: list[str]) -> tuple[bool, str]:
    """Return (allowed, reason). Deterministic checks decide ~90% of cases."""

    # ── deterministic layer: database facts, instant + auditable ──────────────
    if account["do_not_contact"]:
        return False, "suppressed: do-not-contact"
    if account["has_open_deal"]:
        return False, "suppressed: open deal (a rep owns it)"
    if account["human_touch_within_60d"]:
        return False, "suppressed: recent 1:1 human touch"
    if account["outbound_touch_within_14d"]:
        return False, "suppressed: cross-channel cooldown"

    # ── AI layer: the one job only a language model can do — read a free-text
    #    note for a human instruction no column captures. Fails OPEN (a model
    #    outage must never silently block outreach), and is only invoked when
    #    notes actually exist, so most accounts never pay for it.
    if recent_notes:
        if _note_says_do_not_contact(recent_notes):
            return False, "suppressed: 'do not contact' found in a note"

    return True, "clear"


def _note_says_do_not_contact(notes: list[str]) -> bool:
    prompt = (
        "Answer only YES or NO. YES = the notes contain an explicit wish NOT to "
        "contact this company (don't call, don't write). NO = nothing like that."
    )
    body = json.dumps({
        "model": "gpt-4o-mini", "max_tokens": 3, "temperature": 0,
        "messages": [
            {"role": "system", "content": prompt},
            {"role": "user", "content": "\n".join(notes[:10])},
        ],
    }).encode()
    try:
        req = urllib.request.Request(
            "https://api.llm.example/v1/chat/completions", data=body,
            headers={"Authorization": f"Bearer {LLM_KEY}", "Content-Type": "application/json"})
        out = json.loads(urllib.request.urlopen(req, timeout=15).read())
        return out["choices"][0]["message"]["content"].strip().upper().startswith("YES")
    except Exception:
        return False  # fail open — an LLM outage never blocks the pipeline


if __name__ == "__main__":
    acct = {
        "do_not_contact": False, "has_open_deal": False,
        "human_touch_within_60d": False, "outbound_touch_within_14d": False,
    }
    print(gate(acct, recent_notes=[]))  # -> (True, 'clear')
