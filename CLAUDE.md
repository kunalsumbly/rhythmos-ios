# RhythmOS — project context for Claude Code

> The native iOS (SwiftUI) build of **Rhythm** — time management reframed as self-care:
> a time/procrastination coach for one user (a senior engineer), shareable.
>
> **Read `PHILOSOPHY.md` first** — it is the *why* and the bright lines. This file is the
> *how* (stack + build). When *how* and *why* conflict, **why wins.**
>
> The web app at `../rhythm-app` (Vite + React) is the **validated proof / reference** for
> every feature and all the copy/design. This project is the real product going forward.

---

## 1. Tech stack (decided — don't change without asking)

- **SwiftUI**, iOS app. Swift **5** language mode (avoid Swift-6 strict-concurrency friction
  for now). Min deployment **iOS 18**. **iPhone-only** (`TARGETED_DEVICE_FAMILY = 1`).
- **XcodeGen** owns the project: edit **`project.yml`**, then regenerate. The generated
  **`RhythmOS.xcodeproj` is gitignored** — never hand-edit it; change `project.yml` instead.
- **Ponytail**: fewest files, no speculative architecture, no enterprise overhead
  (no fastlane / SwiftLint / CocoaPods / Core+Features layering — that's the *other* repo).
  **Ask before adding any SPM dependency.** Most "intelligence" is rules, not AI (§5).
- Icons: SF Symbols. Styling: a shared `Theme` (design tokens), native SwiftUI views.

---

## 2. Build & run

```sh
xcodegen generate
xcodebuild -project RhythmOS.xcodeproj -scheme RhythmOS \
  -destination 'generic/platform=iOS Simulator' build      # verified: BUILD SUCCEEDED
```
Open `RhythmOS.xcodeproj` in Xcode to run on a simulator or your iPhone (a **free Apple ID**
is enough for your own device; the $99/yr account is only for App Store + remote push).
After adding/removing source files, re-run `xcodegen generate`.

---

## 3. Project structure (`Sources/`)

| File | Holds |
|------|-------|
| `Theme.swift` | Design tokens — the palette (`bg/surface/surface2/line/ink/muted/amber/sage/clay`) + `Color(hex:)`. amber = peak/focus, sage = recovery/calm, clay = depletion/warning. |
| `Models.swift` | `Block`, `DayMode`, and the seed `Schedule` (Kunal's real week) + `isOfficeDay`. |
| `RhythmOSApp.swift` | `@main` app + `RootView` (3-tab `TabView`) + `USER_NAME`. |
| `Screens.swift` | `TodayView` / `ReflectView` / `CoachView`. |

App structure = **3 tabs** (matches the web IA): **Today** (the day), **Reflect** (zoom out),
**Coach** (unblock). The app opens on Today.

---

## 4. The user's real schedule (drives office/home logic — keep accurate)

- **Office days = Tue/Wed/Thu.** Wake 7–7:30, office ~10, meetings, lunch+walk noon, leave 5:30,
  home ~7, exercise, dinner ~9, **deep work 1.5–2 hrs after dinner (~21:00)**, bed 11:30–12.
- **Home days = Mon/Fri (WFH).** No commute. **Protected morning deep block 9:00–11:30.**
  Monday = fast day + week planning; Friday = review.
- `Schedule.isOfficeDay` uses `Calendar` weekday **3/4/5** (Tue/Wed/Thu; 1 = Sun).

---

## 5. Data, storage & architecture (the decisions already made)

- **Starts local**: the schedule is a seed in `Models.swift`. Roadmap: user-editable schedule,
  then a backend. Don't design surveillance — accountability is **self-report**.
- **Crown-jewel data** (mood / "feeling low" / check-in notes) stays **on-device or E2E**, never
  monetised. Lower-sensitivity operational data may be server-side later (minimised).
- **Backend ratified** for accountability / commitment-stakes / sync — local-first otherwise,
  **never analytics or tracking.**
- **Privacy by architecture, not policy** (acquisition-proof). **Consent-gated decryption is
  client-side** — the device holds the keys; the server only ever holds ciphertext + operational
  data.
- **On-device intelligence first**: rules (`pickNudge`/`heroPhase`/`dayScore` pattern) before AI.
  An LLM is only for the **language** layer; now native, **Apple Foundation Models** are
  first-class for that. **Decisions/penalties stay rule-bounded** (LLM may propose, never silently
  execute). Cloud LLM = **Claude**, non-crown-jewel + user-consented data only.
- **Local notifications** (on-device scheduled) for reminders — no server push. Never fragment
  the deep block.

---

## 6. Guardrails

- **Port faithfully**: preserve the web app's copy and design when bringing features over.
- The Coach **"feeling low" → human-support** branch is **sacred** — never gamify it, never turn
  it into productivity advice, never soften the hand-off.
- **Not a psychologist. Not an engagement machine.** Any future stakes carry the **compassion
  override** (pause on wellbeing dips; user-pausable; first miss free; breach = information).
- Don't hand-edit `RhythmOS.xcodeproj`. Don't add SPM deps or enterprise tooling without asking.
- Check every feature against `PHILOSOPHY.md` before building it.

---

## 7. Task tracking — beads (`bd`)

Use **`bd`** for all task tracking (not TODO lists). `bd ready` for available work,
`bd show <id>` for detail, `bd update <id> --claim`, `bd close <id>`. Roadmap epics live here;
the web app's completed build/refactor/v2 epics stay in `../rhythm-app`'s history.


<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:6cd5cc61 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->
