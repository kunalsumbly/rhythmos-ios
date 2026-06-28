import SwiftUI

let USER_NAME = "Kunal"

@main
struct RhythmOSApp: App {
    @StateObject private var store = Store()
    var body: some Scene {
        WindowGroup { RootView().environmentObject(store) }
    }
}

// 3 tabs — Today (the day), Reflect (zoom out), Coach (unblock). Matches the web app's IA.
struct RootView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        TabView(selection: $store.tab) {
            TodayView().tabItem { Label("Today", systemImage: "sun.max") }.tag("today")
            ReflectView().tabItem { Label("Reflect", systemImage: "calendar") }.tag("reflect")
            CoachView().tabItem { Label("Coach", systemImage: "location.north.circle") }.tag("coach")
        }
        .tint(Theme.amber)
        .preferredColorScheme(.dark)
    }
}
