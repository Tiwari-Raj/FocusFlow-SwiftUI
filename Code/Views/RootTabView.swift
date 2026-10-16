import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem { Label("Timer", systemImage: "timer") }

            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
