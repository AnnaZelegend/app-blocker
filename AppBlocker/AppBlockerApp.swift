import SwiftUI

@main
struct AppBlockerApp: App {
    @StateObject private var store = BlockedAppsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
