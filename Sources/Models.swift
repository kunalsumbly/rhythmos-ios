import Foundation

enum DayMode: String { case office, home }

struct Block: Identifiable, Decodable {
    let id = UUID()
    let time: String
    let label: String
    let sub: String
    let kind: String // "amber" | "sage" | "plain"
    enum CodingKeys: String, CodingKey { case time, label, sub, kind }
}

struct Practice: Identifiable, Decodable {
    let id: String
    let icon: String      // SF Symbol
    let accent: String    // "amber" | "sage"
    let label: String
    let detail: String
}

struct HeroSpec: Decodable {
    let time: String
    let label: String
    let sub: String
    let start: Double
    let end: Double
}

struct ArcMarker: Identifiable, Decodable {
    let id = UUID()
    let t: Double
    let e: Double
    let label: String
    let accent: String
    let above: Bool
    enum CodingKeys: String, CodingKey { case t, e, label, accent, above }
}

struct ArcSpec: Decodable {
    let pts: [[Double]]
    let markers: [ArcMarker]
}

struct ScheduleData: Decodable {
    let hero: [String: HeroSpec]
    let blocks: [String: [Block]]
    let practices: [String: [Practice]]
    let arc: [String: ArcSpec]
}

enum HeroPhase { case before, during, after }

struct Check {
    let q: String
    let opts: [String]
}

let CHECKS = [
    Check(q: "Whose agenda ran today?", opts: ["I drove it", "Mixed", "It drove me"]),
    Check(q: "The tank, right now?", opts: ["Charged", "Okay", "Running low"]),
]

// Schedule data is EXTERNALISED to Resources/schedule.json (the seed).
// ponytail: loaded once from the bundle. Upgrade path (epic kbv): swap `load()` for a
// backend API call + local cache — views/API below stay unchanged.
enum Schedule {
    static let data: ScheduleData = load()

    private static func load() -> ScheduleData {
        guard let url = Bundle.main.url(forResource: "schedule", withExtension: "json"),
              let raw = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(ScheduleData.self, from: raw)
        else { fatalError("schedule.json is missing or invalid in the app bundle") }
        return decoded
    }

    static func hero(_ mode: DayMode) -> HeroSpec { data.hero[mode.rawValue]! }
    static func blocks(_ mode: DayMode) -> [Block] { data.blocks[mode.rawValue] ?? [] }
    static func practices(_ mode: DayMode) -> [Practice] { data.practices[mode.rawValue] ?? [] }
    static func arc(_ mode: DayMode) -> ArcSpec { data.arc[mode.rawValue]! }

    // Office days = Tue/Wed/Thu. Calendar weekday: 1=Sun … 7=Sat.
    static func isOfficeDay(_ date: Date = Date()) -> Bool {
        let wd = Calendar.current.component(.weekday, from: date)
        return wd == 3 || wd == 4 || wd == 5
    }

    static func heroPhase(_ mode: DayMode, _ now: Date = Date()) -> (phase: HeroPhase, hoursUntil: Double) {
        let c = Calendar.current
        let h = Double(c.component(.hour, from: now)) + Double(c.component(.minute, from: now)) / 60
        let b = hero(mode)
        if h < b.start { return (.before, b.start - h) }
        if h < b.end { return (.during, 0) }
        return (.after, 0)
    }
}

func dayScore(_ f: Feel) -> Int {
    var s = 0
    if let a = f.agenda { s += 2 - a }
    if let e = f.energy { s += 2 - e }
    return s
}

// last n date keys, oldest → newest, including today
func lastNDates(_ n: Int) -> [String] {
    let cal = Calendar.current
    return (0..<n).reversed().compactMap { i in
        cal.date(byAdding: .day, value: -i, to: Date()).map(todayKey)
    }
}

struct Nudge { let text: String; let to: String?; let accent: String }

// One calm, contextual nudge for the top of Today, or nil.
// Emotional low-run cue wins (→ Coach); else a late wind-down reminder; else nothing.
// Never pings, never guilt; deep-block timing is the hero's job, not duplicated here.
func pickNudge(_ mode: DayMode, feels: [String: Feel], now: Date = Date()) -> Nudge? {
    let recent = lastNDates(4).compactMap { feels[$0] }.filter { $0.agenda != nil || $0.energy != nil }
    if recent.count >= 2 && recent.filter({ dayScore($0) < 2 }).count >= 2 {
        return Nudge(text: "The last few days have felt heavy. Be kind to yourself — Coach can help if it lingers.", to: "coach", accent: "clay")
    }
    let windDown: Double = mode == .office ? 23 : 22.5
    let c = Calendar.current
    let h = Double(c.component(.hour, from: now)) + Double(c.component(.minute, from: now)) / 60
    if h >= windDown {
        return Nudge(text: "Wind-down time — ease off deep work and protect the sleep.", to: nil, accent: "sage")
    }
    return nil
}
