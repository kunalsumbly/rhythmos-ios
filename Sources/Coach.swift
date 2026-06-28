import SwiftUI

// ---------- data ----------
struct CoachResource: Identifiable {
    let id = UUID()
    let type: String   // "Book" | "Listen" | "Idea"
    let icon: String   // SF Symbol
    let title: String
    let by: String
}

struct ProbeOption: Identifiable {
    let id = UUID()
    let text: String
    let to: String?    // redirect to another category id
    let k: String?     // "recent" | "ongoing" (the LOW branch)
    init(_ text: String, to: String? = nil, k: String? = nil) { self.text = text; self.to = to; self.k = k }
}

struct CoachCat: Identifiable {
    let id: String
    let label: String
    let icon: String
    let accent: String      // "amber" | "sage" | "clay"
    let probeQ: String
    let probeOpts: [ProbeOption]
    var root: String? = nil
    var reframe: String? = nil
    var tryNow: String? = nil
    var resources: [CoachResource] = []
    var fit: String? = nil
}

enum Coach {
    static let cats: [CoachCat] = [
        CoachCat(id: "start", label: "I can't get started", icon: "play.circle", accent: "amber",
                 probeQ: "When you sit down to start, it’s mostly…",
                 probeOpts: [ProbeOption("I don't know where to begin"), ProbeOption("It feels heavy or unpleasant"), ProbeOption("I get distracted within minutes", to: "distract")],
                 root: "Avoidance, not laziness",
                 reframe: "The task is vague, aversive, or too big, so starting feels like a cliff. Avoidance is information about the task, not a verdict on you.",
                 tryNow: "Shrink the on-ramp. Commit to 10 minutes on the smallest first slice — open the file, write the signature. Starting is the whole fight.",
                 resources: [CoachResource(type: "Book", icon: "book", title: "Atomic Habits", by: "James Clear — frictionless first steps"),
                             CoachResource(type: "Listen", icon: "headphones", title: "Deep Questions", by: "Cal Newport’s podcast"),
                             CoachResource(type: "Idea", icon: "lightbulb", title: "“Resistance”", by: "Pressfield, The War of Art")],
                 fit: "Decide the one problem on your commute home, so 9pm is start, never decide."),
        CoachCat(id: "distract", label: "I start, then get pulled away", icon: "bolt", accent: "amber",
                 probeQ: "What pulls you, most often?",
                 probeOpts: [ProbeOption("Slack / notifications"), ProbeOption("My own wandering mind"), ProbeOption("People interrupting")],
                 root: "Your environment is winning",
                 reframe: "Attention leaks faster than you can refill it. Every interruption costs ~20 minutes of re-entry, so a quick check is never quick.",
                 tryNow: "One tab, phone in another room, Focus mode on. Protect the re-entry cost, not just the minutes.",
                 resources: [CoachResource(type: "Book", icon: "book", title: "Deep Work", by: "Cal Newport"),
                             CoachResource(type: "Listen", icon: "headphones", title: "Huberman Lab", by: "focus, dopamine & attention"),
                             CoachResource(type: "Idea", icon: "lightbulb", title: "“Attention residue”", by: "Sophie Leroy")],
                 fit: "This is what your Deep Work Focus automation is for — the night block needs it too."),
        CoachCat(id: "drained", label: "I'm just too drained", icon: "battery.25", accent: "sage",
                 probeQ: "The drain feels mostly…",
                 probeOpts: [ProbeOption("Physical — tired, foggy"), ProbeOption("Mental — fried from switching"), ProbeOption("Both, most days", to: "low")],
                 root: "A fuel problem, not a time problem",
                 reframe: "You can’t out-discipline under-recovery. When the tank is empty, willpower just borrows against tomorrow.",
                 tryNow: "Protect sleep first — tighten the wind-down boundary. Put the hardest task in your real peak, not the leftover hours.",
                 resources: [CoachResource(type: "Book", icon: "book", title: "Why We Sleep", by: "Matthew Walker"),
                             CoachResource(type: "Listen", icon: "headphones", title: "Huberman Lab", by: "the sleep toolkit episodes"),
                             CoachResource(type: "Idea", icon: "lightbulb", title: "Chronotypes", by: "“When” by Daniel Pink")],
                 fit: "Your night block ends before bed by design. If drained, tighten that guardrail first."),
        CoachCat(id: "overloaded", label: "Too much on my plate", icon: "square.stack.3d.up", accent: "sage",
                 probeQ: "Where’s the volume coming from?",
                 probeOpts: [ProbeOption("I keep saying yes"), ProbeOption("Work keeps expanding"), ProbeOption("Can't tell what matters most")],
                 root: "Volume, not focus",
                 reframe: "No system survives an over-full plate. The issue isn’t how you work, it’s how much. Something has to visibly come off.",
                 tryNow: "Name the one outcome that matters this week. Let the rest be openly “not now,” not silently dropped.",
                 resources: [CoachResource(type: "Book", icon: "book", title: "Essentialism", by: "Greg McKeown"),
                             CoachResource(type: "Listen", icon: "headphones", title: "Deep Dive", by: "Ali Abdaal on prioritisation"),
                             CoachResource(type: "Idea", icon: "lightbulb", title: "Four Thousand Weeks", by: "Oliver Burkeman")],
                 fit: "Your Friday review is the place to cut, not only to plan."),
        CoachCat(id: "meaning", label: "I don't see the point", icon: "location.north.circle", accent: "amber",
                 probeQ: "The flatness is about…",
                 probeOpts: [ProbeOption("This project specifically"), ProbeOption("Work in general lately"), ProbeOption("Hard to say — just grey", to: "low")],
                 root: "A why-gap",
                 reframe: "Motivation follows clarity of why. When work feels cut off from what you value, the tank reads empty even when rested.",
                 tryNow: "Reconnect the task to its one-step-removed why — this migration builds the skills, the skills build the path you want.",
                 resources: [CoachResource(type: "Book", icon: "book", title: "Drive", by: "Daniel Pink"),
                             CoachResource(type: "Listen", icon: "headphones", title: "The Tim Ferriss Show", by: "building a life’s work"),
                             CoachResource(type: "Idea", icon: "lightbulb", title: "Man's Search for Meaning", by: "Viktor Frankl")],
                 fit: "Tie your study slot to where you want to be, not just the job in front of you."),
        CoachCat(id: "perfect", label: "I keep beating myself up", icon: "heart", accent: "sage",
                 probeQ: "The harsh voice shows up when…",
                 probeOpts: [ProbeOption("I miss a block or a day"), ProbeOption("The work isn’t good enough"), ProbeOption("I compare to others")],
                 root: "All-or-nothing thinking",
                 reframe: "One missed block becomes “I’ve blown it,” so you abandon the week. The harsh voice acts like a saboteur, not a standard-keeper.",
                 tryNow: "Never miss twice. One miss is noise. Skip the guilt loop and protect the next block — that’s the whole repair.",
                 resources: [CoachResource(type: "Book", icon: "book", title: "Self-Compassion", by: "Kristin Neff"),
                             CoachResource(type: "Listen", icon: "headphones", title: "Ten Percent Happier", by: "Dan Harris on the inner critic"),
                             CoachResource(type: "Idea", icon: "lightbulb", title: "“Never miss twice”", by: "James Clear")],
                 fit: "This is why the check-in says: don’t redesign the week, just keep one promise."),
    ]

    // The SACRED wellbeing branch — routes to human support, never productivity advice. Do not gamify.
    static let low = CoachCat(id: "low", label: "Honestly, I just feel low", icon: "cloud.rain", accent: "clay",
                              probeQ: "Has this been around a while?",
                              probeOpts: [ProbeOption("Just today / this week", k: "recent"),
                                          ProbeOption("A couple of weeks or more", k: "ongoing"),
                                          ProbeOption("Things I enjoy feel grey too", k: "ongoing")])

    static func cat(_ id: String?) -> CoachCat? {
        id == "low" ? low : cats.first { $0.id == id }
    }
}

private func themeColor(_ accent: String) -> Color {
    accent == "amber" ? Theme.amber : accent == "clay" ? Theme.clay : Theme.sage
}

// ---------- view ----------
struct CoachView: View {
    enum Step { case pick, probe, result }
    @State private var catId: String? = nil
    @State private var step: Step = .pick
    @State private var probe: ProbeOption? = nil

    private var cat: CoachCat? { Coach.cat(catId) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Coach").font(.system(.largeTitle, design: .rounded).weight(.semibold)).foregroundStyle(Theme.ink)
                    Spacer()
                    Text("what's in the way?").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted)
                }
                switch step {
                case .pick: pickView
                case .probe: if let c = cat { probeView(c) }
                case .result: resultView
                }
            }
            .padding(20)
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private func pick(_ id: String) { catId = id; probe = nil; step = .probe }
    private func onProbe(_ o: ProbeOption) {
        if catId != "low", let to = o.to { catId = to; probe = nil; step = .probe; return }
        probe = o; step = .result
    }
    private func reset() { catId = nil; probe = nil; step = .pick }

    // pick: intro + grid + low
    private var pickView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("When a block keeps slipping, the reason matters more than the willpower. Name it, and the help gets specific.")
                .font(.subheadline).foregroundStyle(Theme.muted)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)], spacing: 9) {
                ForEach(Coach.cats) { c in catButton(c) }
            }
            catButton(Coach.low, fullWidth: true)
        }
    }

    private func catButton(_ c: CoachCat, fullWidth: Bool = false) -> some View {
        Button { pick(c.id) } label: {
            HStack(spacing: 10) {
                Image(systemName: c.icon).font(.system(size: 18)).foregroundStyle(themeColor(c.accent))
                Text(c.label).font(.system(.subheadline, design: .rounded).weight(.medium)).foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fullWidth ? Theme.surface2 : Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }.buttonStyle(.plain)
    }

    private func backButton() -> some View {
        Button { reset() } label: {
            Label("back", systemImage: "chevron.left").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted)
        }.buttonStyle(.plain)
    }

    private func chip(_ c: CoachCat) -> some View {
        HStack(spacing: 7) {
            Image(systemName: c.icon).font(.system(size: 13))
            Text(c.label).font(.system(.caption2, design: .monospaced))
        }
        .foregroundStyle(themeColor(c.accent))
        .padding(.horizontal, 12).padding(.vertical, 6)
        .overlay(Capsule().stroke(Theme.line))
    }

    private func probeView(_ c: CoachCat) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            backButton()
            chip(c)
            Text(c.probeQ).font(.system(.title3, design: .rounded).weight(.medium)).foregroundStyle(Theme.ink)
            VStack(spacing: 8) {
                ForEach(c.probeOpts) { o in
                    Button { onProbe(o) } label: {
                        HStack { Text(o.text).font(.subheadline).foregroundStyle(Theme.ink); Spacer() }
                            .padding(13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.surface2)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(18).card()
    }

    @ViewBuilder private var resultView: some View {
        if catId == "low" { lowResult } else if let c = cat { normalResult(c) }
    }

    private func normalResult(_ c: CoachCat) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            backButton()
            chip(c)
            VStack(alignment: .leading, spacing: 2) {
                Text("Likely root:").font(.caption).foregroundStyle(Theme.muted)
                Text(c.root ?? "").font(.system(.title3, design: .rounded).weight(.semibold)).foregroundStyle(Theme.ink)
            }
            Text(c.reframe ?? "").font(.subheadline).foregroundStyle(Theme.ink.opacity(0.92))
            // Try now
            VStack(alignment: .leading, spacing: 5) {
                Text("TRY NOW").font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.amber)
                Text(c.tryNow ?? "").font(.subheadline).foregroundStyle(Theme.ink)
            }
            .padding(13).frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface2)
            .overlay(Rectangle().fill(Theme.amber).frame(width: 2), alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            // resources
            VStack(spacing: 0) {
                ForEach(Array(c.resources.enumerated()), id: \.element.id) { i, r in
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: r.icon).font(.system(size: 15)).foregroundStyle(Theme.sage).frame(width: 20)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(r.type.uppercased()).font(.system(size: 9, design: .monospaced)).foregroundStyle(Theme.muted)
                            Text(r.title).font(.system(.subheadline, design: .rounded).weight(.semibold)).foregroundStyle(Theme.ink)
                            Text(r.by).font(.caption).foregroundStyle(Theme.muted)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 11)
                    if i < c.resources.count - 1 { Divider().overlay(Theme.line) }
                }
            }
            // in your rhythm
            VStack(alignment: .leading, spacing: 5) {
                Text("IN YOUR RHYTHM").font(.system(size: 9, design: .monospaced)).foregroundStyle(Theme.sage)
                Text(c.fit ?? "").font(.subheadline).foregroundStyle(Theme.ink)
            }
            .padding(13).frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.sage.opacity(0.10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            // restart
            Button { reset() } label: {
                Label("Something else is in the way", systemImage: "arrow.counterclockwise")
                    .font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity).padding(11)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1, dash: [4])).foregroundStyle(Theme.line))
            }.buttonStyle(.plain)
        }
        .padding(18).card()
    }

    private var lowResult: some View {
        let ongoing = probe?.k == "ongoing"
        return VStack(alignment: .leading, spacing: 14) {
            backButton()
            chip(Coach.low)
            if ongoing {
                Text("A low stretch that’s hung around for a couple of weeks — or that’s draining the colour out of things you used to enjoy — is worth taking seriously, and it’s genuinely not something a schedule is built to fix. That’s not a failure of yours.")
                    .font(.system(.body, design: .rounded).weight(.medium)).foregroundStyle(Theme.ink)
                Text("The most useful next step isn’t a productivity tweak — it’s talking it through with someone: a GP, a counsellor, or a person you trust. You don’t have to push through it alone.")
                    .font(.subheadline).foregroundStyle(Theme.ink.opacity(0.9))
                ctaBox("If it would help, ask Claude to find current support options near you in Australia.")
            } else {
                Text("Some days just sit heavy, and that’s allowed. A flat day isn’t a broken rhythm — pushing harder is usually the wrong answer.")
                    .font(.system(.body, design: .rounded).weight(.medium)).foregroundStyle(Theme.ink)
                Text("Lighten the load on purpose today: do the one thing that matters, take the walk, let the rest wait. If the heaviness keeps showing up over the next couple of weeks, that’s worth talking through with someone you trust or a GP.")
                    .font(.subheadline).foregroundStyle(Theme.ink.opacity(0.9))
                ctaBox("No streak to protect today. Just be a bit kind to yourself.")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.clay))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func ctaBox(_ text: String) -> some View {
        Text(text).font(.subheadline).foregroundStyle(Theme.muted)
            .padding(13).frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
