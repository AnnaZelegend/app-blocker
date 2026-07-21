import SwiftUI

struct ContentTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Block Now", systemImage: "lock") }
            ScheduleView()
                .tabItem { Label("Schedule", systemImage: "clock") }
        }
    }
}
