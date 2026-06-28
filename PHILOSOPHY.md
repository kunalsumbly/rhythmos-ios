# Rhythm — core philosophy

> The guiding principles for the app. Every feature, every line of copy, every nudge
> is checked against this. If a proposed change doesn't serve a principle here — or
> crosses a line in "What Rhythm is NOT" — we don't build it, however clever it is.
> This file outranks convenience. When in doubt, re-read it.
>
> *This is the native Swift/SwiftUI build (`rhythmos-ios`). The web app at `../rhythm-app`
> was the validated proof of these ideas and stays as a reference. The philosophy is
> stack-agnostic — it didn't change when the stack did.*

---

## The one-sentence purpose

**Rhythm helps one person manage their time by discovering their own rhythm, then
protecting it — blocking the day against distraction so deep work actually happens —
with a live coach that nudges, reflects emotion back, and clears the blocks that
cause procrastination.**

---

## The core principles

1. **Discover the rhythm, don't impose a system.**
   The app's job is to help the user *see* and *protect* the natural shape of their day
   and week (home days vs office days, peaks vs recovery), not to bolt on a generic
   productivity methodology. The rhythm is theirs; we make it visible.

2. **Protect deep work above all.**
   The single most valuable thing the app does is guard the one unbroken deep-work block
   each day. Distraction is the enemy. Everything that fragments that block — including
   the app itself with too many pings — works against the mission.

3. **Be a live coach, not a static checklist.**
   The app should feel like something that *knows what time it is* and speaks to the
   moment: before a block ("clear the runway"), during it ("phone away, start"),
   after it ("did you get it?"). A silent checkbox is not coaching. Time-awareness is.

4. **Use emotional cues, honestly.**
   Reflect back how the day/week actually felt (energy, whose agenda ran the day) and
   speak to it plainly. Emotion is signal, not decoration — but we never manipulate it
   or manufacture urgency/guilt to drive engagement.

5. **Confirmation reduces self-sabotage.**
   Ask the user to confirm the work they did. Naming "I protected the block" / "I didn't"
   turns a vague day into something they can see and act on. The act of confirming is the
   feature — it closes the loop and cuts the quiet drift that sabotages good intentions.

6. **Help overcome procrastination at the root.**
   When a block keeps slipping, the *reason* matters more than willpower. Name the
   specific blocker → give the likely root cause → one small thing to try now.
   Avoidance is information about the task, not a verdict on the person.

7. **Curate real resources — never hallucinate them.**
   For a specific issue, point to genuinely useful, real resources (books, talks,
   YouTube, articles). Titles and authors must be real and vetted. Empathic framing can
   be generated; **resource facts cannot.** A made-up book is a betrayal of trust.

8. **Aim for charged, not full.**
   Success is not a maxed-out checklist. A good day is one where the one deep block and
   the recovery both happened. The app should relieve pressure, not add a new source of it.

9. **Never miss twice.**
   One missed block is noise. The response to a miss is to protect the *next* one — never
   a guilt spiral, never "you've blown the week." The app is a repair tool, not a judge.

10. **Local-first, private, calm.**
    Local-first is the default — anything that *can* live only on the device, does.
    A backend/accounts is allowed **only** where a feature genuinely requires it
    (accountability, commitment/stakes, sync), never for analytics or tracking.
    Mobile-first (iPhone), quiet, and personal. (See "Direction (2026-06-28)" below — the
    app is evolving from a local-only self-care tool toward an accountability platform, and
    the data-trust rules that make that safe.)

---

## What Rhythm is NOT (the bright lines — never cross)

- **Not a psychologist / not a therapist.** Rhythm coaches *time and procrastination*,
  not mental health. When something reads as low mood — especially if it's lingered for
  weeks or is draining colour from things the user used to enjoy — the app does NOT offer
  a productivity tweak. It routes to **human support (a GP, counsellor, or trusted
  person)** and says so plainly. This is the "feeling low" branch in Coach. It is sacred:
  never gamify it, never turn it into productivity advice, never soften the hand-off.

- **Not an engagement machine.** No streaks-as-pressure, no manufactured guilt, no
  constant pings. Nudges serve the user's deep work; they never fragment it to juice
  "time in app." If a nudge would interrupt the very block it's meant to protect, it's wrong.

- **Not a generic to-do app or calendar.** It is not trying to capture every task or
  replace a calendar. It protects the few things that matter and lets the rest be openly
  "not now."

- **Data is held in trust, never the revenue source.** (This replaces the old blunt
  "not a data product" line — that was a proxy for the real principle.) The business
  model aligns with the user's **success**, not their attention or failure: no ads, no
  selling data, no engagement-maxxing, and — per the stakes idea — **no forfeit ever goes
  to the developer**. Wellbeing/mood data gets the strongest protection and is never
  monetised. See "Privacy by architecture" below for how this survives a change of owner.

---

## Direction (2026-06-28) — the accountability pivot + the native commitment

The app is deliberately evolving from a **local-only calm self-care tool** toward an
**accountability / commitment platform** (real interaction drives honesty; calm ≠ passive).
And it is now a **native iOS app (Swift/SwiftUI)** — the web app proved the ideas; native
is the real product. This unlocks a backend and first-class device features, but only under
hard rules:

- **Backend ratified, local-first default.** A server/accounts may exist for accountability,
  commitment/stakes, and sync. Everything that doesn't *need* the server stays on-device.

- **Privacy by architecture, not policy (acquisition-proof).** A privacy policy can't hold
  trust across a sale — a new owner just rewrites it. So the **crown jewels** (mood, the
  "feeling low" signals, check-in notes) are protected by *architecture*: end-to-end
  encrypted or kept on-device, so **no operator — present or future — can read or monetise
  them**, whatever the policy says. Lower-sensitivity *operational* data (schedule, adherence
  marks, stakes ledger) may be server-side under **data-minimisation + a successor-binding
  commitment**. Always provide **full export + hard delete**; prefer an **open-source client**
  so the encryption claims are verifiable. Consent-gated decryption is **client-side**: the
  device holds the keys and decrypts only what the user consents to share; the server never
  holds the keys. Explicit trade-off: the more the server must *read* data, the less it can
  be E2E-encrypted — so crown-jewel intelligence runs on-device.

- **On-device intelligence first.** Most "intelligence" here is **rules, not AI** —
  thresholds, matrices, history counts (the `pickNudge` / `heroPhase` / `dayScore` pattern),
  which run on-device for free. An LLM is needed only for the **language** layer (free-text
  understanding — e.g. the adaptive Coach probe, empathic phrasing). Because we went native,
  **Apple's on-device Foundation Models are now first-class** for that language layer.
  Penalty/escalation **decisions stay rule-bounded and auditable**: an LLM may
  *propose/explain*, never silently execute. Only **non-sensitive, user-approved** snippets
  go to a cloud LLM (**Claude** — the Anthropic API doesn't train on inputs by default,
  which keeps the consent story honest).

- **Native unlocks (decided).** The PWA→native fork is **resolved: native.** That gives
  **local notifications** (on-device scheduled reminders — no server push needed), the
  on-device LLM above, Keychain, and StoreKit (for any future stakes). Reminders must still
  never fragment the deep block.

- **These bright lines survive the pivot, unchanged:** the **"feeling low" → human-support**
  branch (above), and — for any future stakes — a **compassion override**: pause penalties
  entirely on any wellbeing-dip signal; always user-pausable; first miss is free; a breach is
  *information, not a verdict*; stakes are **user-chosen self-accountability, never the app
  punishing**. Still **not a psychologist**, still **not an engagement machine**.

Tracked as beads epics in this project (see `bd ready`): port-to-native · editable schedule ·
accountability loop · local-notification reminders · backend+E2E+consent · on-device LLM
Coach probe · commitment stakes (the last is gated on an explicit decision per the rules above).

---

## How to use this file

- **Before designing or building a feature**, name which principle(s) it serves.
- **If a feature can't be tied to a principle**, that's a signal it doesn't belong.
- **If a feature touches mood, support, or "I feel low,"** stop and re-read the bright
  lines above — that territory is hands-off productivity logic and routes to humans.
- This file is paired with `CLAUDE.md` (the build/tech spec). Where CLAUDE.md says *how*,
  this file says *why*. Why wins.
