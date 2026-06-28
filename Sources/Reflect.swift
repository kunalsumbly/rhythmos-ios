import SwiftUI

private func weekdayShort(_ key: String) -> String {
    let inF = DateFormatter(); inF.dateFormat = "yyyy-MM-dd"
    guard let d = inF.date(from: key) else { return "" }
    let outF = DateFormatter(); outF.dateFormat = "EEE"
    return outF.string(from: d)
}

struct TrendStrip: View {
    let feels: [String: Feel]
    var days: Int = 14
    var body: some View {
        HStack(spacing: 6) {
            ForEach(lastNDates(days), id: \.self) { d in
                let f = feels[d]
                let has = f != nil && (f!.agenda != nil || f!.energy != nil)
                let sc = has ? dayScore(f!) : 0
                let color: Color = !has ? Theme.muted.opacity(0.14)
                    : sc >= 4 ? Theme.sage
                    : sc >= 2 ? Theme.amber.opacity(0.7)
                    : Theme.clay
                RoundedRectangle(cornerRadius: 5)
                    .fill(color)
                    .frame(width: 14, height: 14)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Theme.ink, lineWidth: d == todayKey() ? 1.5 : 0))
            }
        }
    }
}

struct ReflectView: View {
    @EnvironmentObject var store: Store

    private let cadence: [(String, String)] = [
        ("Mon & Fri — home", "Your deep-work days. Unbroken mornings, no commute — stack the heavy thinking here. Monday (fast day) opens with planning; Friday closes with review."),
        ("Tue–Thu — office", "Collaboration days. Let meetings own the middle. One focused night block carries your deep task; the commute carries your study."),
    ]
    private let guardrails = [
        "Stack heavy deep work on Mon & Fri — don't fight the office for four hours it won't give you.",
        "On office days, let the afternoon be collaboration; let the night block carry one deep task, not three.",
        "Commute in is for input — study, audio. Commute home is for decompression.",
        "Stop deep work ~30 min before bed. The 7–7.5 hours of sleep is the floor everything compounds on.",
        "The lunch walk is non-negotiable on office days — your only daylight reset.",
    ]

    var body: some View {
        let week = lastNDates(7).compactMap { store.feels[$0] }.filter { $0.agenda != nil || $0.energy != nil }
        let good = week.filter { dayScore($0) >= 4 }.count
        let low = week.filter { dayScore($0) < 2 }.count
        let reflect = week.isEmpty ? "No check-ins yet this week — two taps each evening is all it takes."
            : low > good ? "A heavy stretch. Be gentle with yourself — if it lingers, Coach can point you to real support."
            : good >= week.count - 1 ? "A good week — the rhythm mostly held."
            : "A mixed week. That’s normal — protect the next block, not the whole week."
        let notes = lastNDates(7).compactMap { d -> (day: String, note: String)? in
            if let n = store.feels[d]?.note, !n.isEmpty { return (d, n) }
            return nil
        }

        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Reflect").font(.system(.largeTitle, design: .rounded).weight(.semibold)).foregroundStyle(Theme.ink)
                    Spacer()
                    Text("looking back").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted)
                }

                // How it's felt
                VStack(alignment: .leading, spacing: 12) {
                    cardHead("How it’s felt", "14 days")
                    TrendStrip(feels: store.feels)
                    Text(reflect).font(.caption).foregroundStyle(Theme.muted)
                }.card()

                // What you said you'd protect
                VStack(alignment: .leading, spacing: 12) {
                    cardHead("What you said you’d protect", "this week", icon: "target")
                    if notes.isEmpty {
                        Text("Your tomorrow-notes show up here as you write them on the check-in.").font(.caption).foregroundStyle(Theme.muted)
                    } else {
                        ForEach(notes, id: \.day) { item in
                            HStack(alignment: .top, spacing: 11) {
                                Text(weekdayShort(item.day).uppercased()).font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.sage).frame(width: 34, alignment: .leading)
                                Text(item.note).font(.subheadline).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }.card()

                Text("YOUR RHYTHM — REFERENCE").font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted).padding(.top, 6)

                // Cadence
                VStack(alignment: .leading, spacing: 14) {
                    cardHead("Cadence", "", icon: "calendar")
                    ForEach(cadence, id: \.0) { day, text in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(day.uppercased()).font(.system(size: 11, design: .monospaced)).foregroundStyle(Theme.amber)
                            Text(text).font(.caption).foregroundStyle(Theme.muted)
                        }
                    }
                }.card()

                // Guardrails
                VStack(alignment: .leading, spacing: 12) {
                    cardHead("Guardrails", "", icon: "shield")
                    ForEach(guardrails, id: \.self) { g in
                        HStack(alignment: .top, spacing: 11) {
                            Circle().fill(Theme.sage).frame(width: 6, height: 6).padding(.top, 6)
                            Text(g).font(.caption).foregroundStyle(Theme.muted).fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                    }
                }.card()

                HStack(spacing: 9) {
                    Image(systemName: "sparkles").foregroundStyle(Theme.amber)
                    Text("Aim for charged, not full. A day where your one deep block and your recovery both happen is a good day.")
                        .font(.caption).foregroundStyle(Theme.muted)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private func cardHead(_ title: String, _ sub: String, icon: String? = nil) -> some View {
        HStack {
            HStack(spacing: 7) {
                if let icon { Image(systemName: icon).font(.system(size: 13)) }
                Text(title.uppercased()).font(.system(.caption, design: .monospaced))
            }.foregroundStyle(Theme.ink)
            Spacer()
            if !sub.isEmpty { Text(sub).font(.system(.caption2, design: .monospaced)).foregroundStyle(Theme.muted) }
        }
    }
}
