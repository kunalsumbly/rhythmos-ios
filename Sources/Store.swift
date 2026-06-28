import SwiftUI

struct Feel: Codable {
    var agenda: Int?
    var energy: Int?
    var note: String?
}

func todayKey(_ d: Date = Date()) -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f.string(from: d)
}

// The one place that knows the storage keys/shapes. Local for now (UserDefaults);
// swaps to backend/E2E later (epic kbv) without touching the views.
final class Store: ObservableObject {
    @Published var tab = "today"                // selected bottom tab
    @Published var done: [String] = []          // today's protected practice ids
    @Published var feels: [String: Feel] = [:]  // date -> check-in

    private let defaults = UserDefaults.standard

    init() {
        done = decode([String].self, "rhythm:day:\(todayKey())") ?? []
        feels = decode([String: Feel].self, "rhythm:feels") ?? [:]
    }

    var curFeel: Feel { feels[todayKey()] ?? Feel() }

    func toggle(_ id: String) {
        if let i = done.firstIndex(of: id) { done.remove(at: i) } else { done.append(id) }
        encode(done, "rhythm:day:\(todayKey())")
    }

    func setFeel(_ field: WritableKeyPath<Feel, Int?>, _ val: Int) {
        var f = curFeel
        f[keyPath: field] = (f[keyPath: field] == val) ? nil : val
        feels[todayKey()] = f
        encode(feels, "rhythm:feels")
    }

    func setNote(_ text: String) {
        var f = curFeel
        f.note = text.isEmpty ? nil : text
        feels[todayKey()] = f
        encode(feels, "rhythm:feels")
    }

    private func decode<T: Decodable>(_ type: T.Type, _ key: String) -> T? {
        guard let d = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: d)
    }

    private func encode<T: Encodable>(_ value: T, _ key: String) {
        if let d = try? JSONEncoder().encode(value) { defaults.set(d, forKey: key) }
    }
}
