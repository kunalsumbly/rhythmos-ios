import SwiftUI

// Design tokens — the same palette as the web app (PHILOSOPHY §9).
// amber = peak/focus, sage = recovery/calm, clay = depletion/warning (sparingly).
enum Theme {
    static let bg = Color(hex: "131D1B")
    static let surface = Color(hex: "1B2926")
    static let surface2 = Color(hex: "213430")
    static let line = Color(hex: "2C413C")
    static let ink = Color(hex: "ECE7DA")
    static let muted = Color(hex: "93A69E")
    static let amber = Color(hex: "E2A65A")
    static let sage = Color(hex: "84B6A1")
    static let clay = Color(hex: "CC7A53")
}

extension Color {
    init(hex: String) {
        let s = Scanner(string: hex.hasPrefix("#") ? String(hex.dropFirst()) : hex)
        var v: UInt64 = 0
        s.scanHexInt64(&v)
        self.init(.sRGB,
                  red: Double((v >> 16) & 0xFF) / 255,
                  green: Double((v >> 8) & 0xFF) / 255,
                  blue: Double(v & 0xFF) / 255,
                  opacity: 1)
    }
}
