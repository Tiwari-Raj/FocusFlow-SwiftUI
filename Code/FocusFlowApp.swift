import SwiftUI

@main
struct FocusFlowApp: App {
    @State private var settingsStore: SettingsStore
    @State private var historyStore: HistoryStore
    @State private var timerViewModel: TimerViewModel

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let settings = SettingsStore()
        let history = HistoryStore()
        _settingsStore = State(initialValue: settings)
        _historyStore = State(initialValue: history)
        _timerViewModel = State(initialValue: TimerViewModel(settings: settings, historyStore: history))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(settingsStore)
                .environment(historyStore)
                .environment(timerViewModel)
                .task {
                    NotificationManager().requestAuthorizationIfNeeded()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        timerViewModel.syncPendingLiveActivityToggle()
                    }
                }
        }
    }
}
