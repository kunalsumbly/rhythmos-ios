import SwiftUI

private func greeting(_ date: Date = Date()) -> String {
    let h = Calendar.current.component(.hour, from: date)
    return h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening"
}

private func accentFor(_ kind: String) -> Color {
    kind == "amber" ? Theme.amber : kind == "sage" ? Theme.sage : Theme.line
}

extension View {
    func card() -> some View {
        self.padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// ---------- shared bits ----------
struct ChargeRing: View {
    let charge: Double
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle().stroke(Theme.line, lineWidth: 5)
            Circle().trim(from: 0, to: charge)
                .stroke(Theme.amber, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

private func smoothPath(_ p: [CGPoint]) -> Path {
    var path = Path()
    guard p.count > 1 else { return path }
    path.move(to: p[0])
    for i in 0..<(p.count - 1) {
        let p0 = i > 0 ? p[i - 1] : p[i]
        let p1 = p[i], p2 = p[i + 1]
        let p3 = (i + 2 < p.count) ? p[i + 2] : p2
        let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
        let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
        path.addCurve(to: p2, control1: c1, control2: c2)
    }
    return path
}

struct ArcView: View {
    let mode: DayMode
    private let ticks: [(Double, String)] = [(7, "7a"), (10, "10a"), (13, "1p"), (16, "4p"), (19, "7p"), (22, "10p")]

    var body: some View {
        GeometryReader { geo in content(geo.size) }
            .frame(height: 160)
    }

    // plain function (not a ViewBuilder) so imperative Path building is allowed
    private func content(_ size: CGSize) -> some View {
        let w = size.width, h = size.height
        let base = h - 22
        let plotH = h - 28
        let X: (Double) -> CGFloat = { CGFloat(($0 - 7) / 17) * w }
        let Y: (Double) -> CGFloat = { 6 + CGFloat(1 - $0) * plotH }
        let spec = Schedule.arc(mode)
        let pts = spec.pts.map { CGPoint(x: X($0[0]), y: Y($0[1])) }
        let line = smoothPath(pts)
        var area = line
        if let first = pts.first, let last = pts.last {
            area.addLine(to: CGPoint(x: last.x, y: base))
            area.addLine(to: CGPoint(x: first.x, y: base))
            area.closeSubpath()
        }
        return ZStack(alignment: .topLeading) {
            area.fill(LinearGradient(colors: [Theme.amber.opacity(0.30), Theme.amber.opacity(0)], startPoint: .top, endPoint: .bottom))
            Path { p in p.move(to: CGPoint(x: 0, y: base)); p.addLine(to: CGPoint(x: w, y: base)) }
                .stroke(Theme.line, lineWidth: 1)
            line.stroke(Theme.amber, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            ForEach(ticks.indices, id: \.self) { i in
                Text(ticks[i].1).font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted)
                    .position(x: X(ticks[i].0), y: h - 9)
            }
            ForEach(spec.markers) { m in
                let c = m.accent == "amber" ? Theme.amber : Theme.sage
                Circle().fill(c).frame(width: 7, height: 7).position(x: X(m.t), y: Y(m.e))
                Text(m.label).font(.system(size: 10, design: .monospaced)).foregroundStyle(c)
                    .position(x: X(m.t), y: Y(m.e) + (m.above ? -14 : 18))
            }
        }
    }
}

// ---------- TODAY ----------
struct TodayView: View {
    @EnvironmentObject var store: Store
    @State private var mode: DayMode = Schedule.isOfficeDay() ? .office : .home
    @State private var declined = false

    private var practices: [Practice] { Schedule.practices(mode) }
    private var charge: Double { practices.isEmpty ? 0 : Double(store.done.count) / Double(practices.count) }

    private var dateLabel: String {
        let f = DateFormatter(); f.dateFormat = "EEEE, d MMMM"
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                nudgeBanner
                heroCard
                toggle
                arcCard
                practicesCard
                checkinCard
            }
            .padding(20)
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    // greeting + badge
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dateLabel.uppercased()).font(.system(.caption2, design: .monospaced)).foregroundStyle(Theme.sage)
                Text("\(greeting()), \(USER_NAME)").font(.system(.largeTitle, design: .rounded).weight(.semibold)).foregroundStyle(Theme.ink)
            }
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: mode == .office ? "building.2" : "house").font(.system(size: 11))
                Text(mode == .office ? "OFFICE DAY" : "HOME DAY").font(.system(.caption2, design: .monospaced))
            }
            .foregroundStyle(mode == .office ? Theme.amber : Theme.sage)
            .padding(.horizontal, 11).padding(.vertical, 6)
            .overlay(Capsule().stroke(Theme.line))
        }
    }

    @ViewBuilder private var nudgeBanner: some View {
        if let n = pickNudge(mode, feels: store.feels) {
            let acc = n.accent == "clay" ? Theme.clay : Theme.sage
            let body = HStack(spacing: 8) {
                Text(n.text).font(.subheadline).foregroundStyle(Theme.ink)
                if n.to != nil { Spacer(minLength: 4); Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(Theme.muted) }
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .overlay(Rectangle().fill(acc).frame(width: 2), alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line))

            if let to = n.to {
                Button { store.tab = to } label: { body }.buttonStyle(.plain)
            } else {
                body
            }
        }
    }

    private var heroCard: some View {
        let b = Schedule.hero(mode)
        let heroDone = store.done.contains("deep")
        let (phase, hoursUntil) = Schedule.heroPhase(mode)
        let until = hoursUntil >= 1 ? "\(Int(hoursUntil.rounded()))h" : "\(max(1, Int((hoursUntil * 60).rounded())))m"
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile").font(.system(size: 12))
                Text("TODAY'S ONE BLOCK TO PROTECT").font(.system(.caption2, design: .monospaced))
            }.foregroundStyle(Theme.amber)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(b.time).font(.system(.body, design: .monospaced)).foregroundStyle(Theme.muted)
                Text(b.label).font(.system(.title2, design: .rounded).weight(.semibold)).foregroundStyle(Theme.ink)
            }
            Text(b.sub).font(.subheadline).foregroundStyle(Theme.muted)

            if heroDone {
                Label("protected today", systemImage: "checkmark").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.sage).padding(.top, 4)
            } else if phase == .before {
                Text("in \(until) — clear the runway").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted).padding(.top, 4)
            } else if phase == .during {
                Text("now — phone away, start").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.amber).padding(.top, 4)
            } else if declined {
                Text("never miss twice — protect tomorrow's").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted).padding(.top, 4)
            } else {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Did you get your deep block?").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.ink)
                    HStack(spacing: 8) {
                        Button { store.toggle("deep") } label: {
                            Label("Protected it", systemImage: "checkmark").font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(Theme.bg).padding(.horizontal, 14).padding(.vertical, 9)
                                .background(Theme.sage).clipShape(RoundedRectangle(cornerRadius: 9))
                        }.buttonStyle(.plain)
                        Button { declined = true } label: {
                            Text("Not today").font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(Theme.muted).padding(.horizontal, 14).padding(.vertical, 9)
                                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Theme.line))
                        }.buttonStyle(.plain)
                    }
                }.padding(.top, 6)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [Theme.surface2, Theme.surface], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line))
        .overlay(Rectangle().fill(Theme.amber).frame(height: 2), alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var toggle: some View {
        HStack(spacing: 8) {
            toggleButton(.office, "building.2", "Office", "Tue–Thu")
            toggleButton(.home, "house", "Home", "Mon · Fri")
        }
    }

    private func toggleButton(_ m: DayMode, _ icon: String, _ title: String, _ days: String) -> some View {
        let on = mode == m
        return Button { mode = m } label: {
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 14))
                Text(title).font(.system(.subheadline, design: .rounded).weight(.medium))
                Text(days).font(.system(size: 9, design: .monospaced)).opacity(0.7)
            }
            .foregroundStyle(on ? Theme.ink : Theme.muted)
            .frame(maxWidth: .infinity).padding(.vertical, 11)
            .background(on ? Theme.surface2 : Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(on ? Theme.amber : Theme.line))
            .clipShape(RoundedRectangle(cornerRadius: 11))
        }.buttonStyle(.plain)
    }

    private var arcCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("THE DAY'S ARC").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.ink)
                Spacer()
                HStack(spacing: 7) {
                    ChargeRing(charge: charge, size: 26)
                    Text("\(store.done.count)/\(practices.count)").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.muted)
                }
            }
            ArcView(mode: mode)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 3), spacing: 7) {
                ForEach(Schedule.blocks(mode)) { b in blockCell(b) }
            }
        }
        .card()
    }

    private func blockCell(_ b: Block) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(b.time).font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted)
            Text(b.label).font(.system(.caption, design: .rounded).weight(.medium)).foregroundStyle(Theme.ink)
            Text(b.sub).font(.system(size: 10)).foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(Theme.surface2)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line))
        .overlay(Rectangle().fill(accentFor(b.kind)).frame(height: 2), alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var practicesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("KEYSTONE PRACTICES").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.ink)
                Spacer()
                Text("check as you go").font(.system(.caption2, design: .monospaced)).foregroundStyle(Theme.muted)
            }
            ForEach(practices) { p in practiceRow(p) }
        }
        .card()
    }

    private func practiceRow(_ p: Practice) -> some View {
        let on = store.done.contains(p.id)
        let acc = p.accent == "amber" ? Theme.amber : Theme.sage
        return Button { store.toggle(p.id) } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7).fill(on ? acc : Color.clear)
                    RoundedRectangle(cornerRadius: 7).stroke(on ? acc : Theme.line, lineWidth: 1.5)
                    if on { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(Theme.bg) }
                }.frame(width: 22, height: 22)
                Image(systemName: p.icon).font(.system(size: 17)).foregroundStyle(acc).frame(width: 22)
                VStack(alignment: .leading, spacing: 3) {
                    Text(p.label).font(.system(.subheadline, design: .rounded).weight(.medium)).foregroundStyle(on ? Theme.muted : Theme.ink)
                    Text(p.detail).font(.caption).foregroundStyle(Theme.muted).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface2)
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Theme.line))
            .clipShape(RoundedRectangle(cornerRadius: 11))
        }.buttonStyle(.plain)
    }

    private var checkinCard: some View {
        let f = store.curFeel
        let bothAnswered = f.agenda != nil && f.energy != nil
        let cueLive = f.agenda == 2 || f.energy == 2
        let msg: String = {
            if !bothAnswered { return "Two taps at shutdown. Naming the day is how the cue becomes something you can act on." }
            if cueLive { return "Cue's live. Don't fix the whole week tonight — just protect tomorrow's one block." }
            if f.agenda == 0 && f.energy == 0 { return "Good day — you drove it and the tank held. Note what made it land." }
            return "Solid enough. Pick the one thing that would make tomorrow lighter."
        }()
        return VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label("Daily check-in", systemImage: "location.north.circle").font(.system(.caption, design: .monospaced)).foregroundStyle(Theme.ink)
                Spacer()
                Text("at shutdown").font(.system(.caption2, design: .monospaced)).foregroundStyle(Theme.muted)
            }
            checkRow(CHECKS[0], selected: f.agenda) { store.setFeel(\.agenda, $0) }
            checkRow(CHECKS[1], selected: f.energy) { store.setFeel(\.energy, $0) }
            Text(msg).font(.caption).foregroundStyle(cueLive ? Theme.ink : Theme.muted)
            VStack(alignment: .leading, spacing: 7) {
                Text("ONE THING YOU'LL PROTECT TOMORROW").font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted)
                TextField("", text: Binding(get: { store.curFeel.note ?? "" }, set: { store.setNote($0) }), prompt: Text("e.g. the 9am deep block, no matter what").foregroundStyle(Theme.muted.opacity(0.7)))
                    .font(.subheadline).foregroundStyle(Theme.ink)
                    .padding(11)
                    .background(Theme.surface2)
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Theme.line))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
            }
        }
        .card()
    }

    private func checkRow(_ check: Check, selected: Int?, _ set: @escaping (Int) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(check.q).font(.system(.subheadline, design: .rounded).weight(.medium)).foregroundStyle(Theme.ink)
            HStack(spacing: 6) {
                ForEach(check.opts.indices, id: \.self) { i in
                    let on = selected == i
                    let c = i == 0 ? Theme.sage : i == 1 ? Theme.amber : Theme.clay
                    Button { set(i) } label: {
                        Text(check.opts[i]).font(.caption).foregroundStyle(on ? Theme.ink : Theme.muted)
                            .frame(maxWidth: .infinity).padding(.vertical, 9)
                            .background(on ? c.opacity(0.18) : Theme.surface2)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(on ? c : Theme.line))
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}

