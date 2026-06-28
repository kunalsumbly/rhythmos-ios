# RhythmOS

**Native iOS (SwiftUI) app — time management reframed as self-care.**

Rhythm helps one person discover their own rhythm and *protect* it — blocking the
day against distraction so deep work actually happens — with a live coach that
nudges, reflects emotion back, and clears the blocks that cause procrastination.

> Read **[PHILOSOPHY.md](PHILOSOPHY.md)** first — it's the *why* and the bright lines
> (what the app must never become). **[CLAUDE.md](CLAUDE.md)** is the build/tech spec.

This is the native build of the web proof at
[rhythm-app](https://github.com/kunalsumbly/rhythm-app).

---

## Screens

- **Today** — a time-aware "one block to protect" hero (with a *Protected it / Not
  today* confirm), an office/home toggle, the day's energy arc + charge ring + time
  blocks, 5 keystone practices (checkable), the daily check-in, and a calm top-of-day
  nudge.
- **Reflect** — a 14-day felt-trend, a supportive weekly line, your "what you said
  you'd protect" notes, and the cadence + guardrails reference.
- **Coach** — pick a symptom → one probe → likely root cause + one thing to try + 3
  real curated resources. A separate **"feeling low"** branch routes to human support
  (GP / counsellor / trusted person), never productivity advice — and is never gamified.

## Tech

- **SwiftUI**, Swift 5 language mode, iOS 18+, iPhone-only.
- **[XcodeGen](https://github.com/yonyz/XcodeGen)** owns the project: edit
  [`project.yml`](project.yml), **not** the generated `.xcodeproj` (it's gitignored).
- No third-party dependencies. Local-first; the schedule is externalised to
  [`Resources/schedule.json`](Resources/schedule.json) behind a loader seam (swaps to a
  backend API later). State persists via a small `Store` over `UserDefaults`.

## Getting started

Requires macOS + Xcode 16+ and XcodeGen (`brew install xcodegen`).

```sh
xcodegen generate                 # regenerate RhythmOS.xcodeproj from project.yml
open RhythmOS.xcodeproj           # then press Run (a free Apple ID works on your own device)
```

Build headlessly:

```sh
xcodebuild -project RhythmOS.xcodeproj -scheme RhythmOS \
  -destination 'generic/platform=iOS Simulator' build
```

## Project structure

```
project.yml            XcodeGen spec (source of truth for the project)
Resources/
  schedule.json        the seed schedule (blocks, hero, practices, energy arc)
Sources/
  RhythmOSApp.swift    @main + the 3-tab RootView
  Theme.swift          design tokens (the palette)
  Models.swift         data model + Schedule loader + heroPhase / pickNudge / scoring
  Store.swift          local persistence (UserDefaults)
  Screens.swift        TodayView + shared bits (charge ring, arc)
  Reflect.swift        ReflectView + trend strip
  Coach.swift          CoachView + the diagnostic content (incl. the "feeling low" branch)
```

## Status & roadmap

Today, Coach, and Reflect are at parity with the web proof. Next, tracked as issues:

- Editable schedule (seed → user override)
- Accountability loop + timely check-ins (self-report)
- Local notifications / reminders
- Backend + accounts + end-to-end encrypted "crown-jewel" data, consent-gated
- On-device LLM Coach probe (Apple Foundation Models)
- Opt-in commitment stakes (charity/anti-charity beneficiary, with a compassion override)
