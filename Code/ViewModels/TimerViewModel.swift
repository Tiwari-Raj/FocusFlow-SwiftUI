import Foundation
import Observation

/// Owns all Pomodoro timer logic: phase transitions, the countdown itself,
/// and fanning updates out to the Live Activity, local notifications and
/// the history log. Views only ever read state or call start/pause/reset/skip.
@Observable
@MainActor
final class TimerViewModel {
    private(set) var phase: PomodoroPhase = .focus
    private(set) var timeRemaining: TimeInterval
    private(set) var isRunning = false
    private(set) var completedFocusSessions = 0

    private var endDate: Date?
    private var sessionStartDate: Date?
    private var ticker: Task<Void, Never>?

    private let settings: SettingsStore
    private let historyStore: HistoryStore
    private let liveActivityManager = LiveActivityManager()
    private let notificationManager = NotificationManager()

    /// Shared with the Widget Extension via an App Group so a tap on the
    /// Live Activity's pause/resume button (which runs in the extension's
    /// process) can signal the running app to catch up next time it's active.
    private let appGroupDefaults = UserDefaults(suiteName: "group.com.touchzing.focusflow")

    var totalDuration: TimeInterval {
        switch phase {
        case .focus: return settings.focusDuration
        case .shortBreak: return settings.shortBreakDuration
        case .longBreak: return settings.longBreakDuration
        }
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(max(1 - (timeRemaining / totalDuration), 0), 1)
    }

    init(settings: SettingsStore, historyStore: HistoryStore) {
        self.settings = settings
        self.historyStore = historyStore
        self.timeRemaining = settings.focusDuration
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        let end = Date().addingTimeInterval(timeRemaining)
        endDate = end
        sessionStartDate = sessionStartDate ?? Date()

        if settings.soundEnabled {
            notificationManager.scheduleEndNotification(for: phase, at: end)
        }
        liveActivityManager.start(
            phase: phase,
            endDate: end,
            sessionNumber: completedFocusSessions + 1,
            totalDuration: totalDuration
        )

        runTicker()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        ticker?.cancel()
        notificationManager.cancelPendingNotification()
        liveActivityManager.update(
            phase: phase,
            endDate: nil,
            remaining: timeRemaining,
            sessionNumber: completedFocusSessions + 1,
            totalDuration: totalDuration,
            isPaused: true
        )
    }

    func reset() {
        ticker?.cancel()
        isRunning = false
        sessionStartDate = nil
        endDate = nil
        timeRemaining = totalDuration
        notificationManager.cancelPendingNotification()
        liveActivityManager.end()
    }

    /// Jumps straight to the next phase without logging a completed session.
    func skip() {
        completeCurrentPhase(wasSkipped: true)
    }

    /// Called when the app becomes active, to apply a pause/resume request
    /// that was made from the Live Activity's button while the app wasn't
    /// running in the foreground.
    func syncPendingLiveActivityToggle() {
        guard appGroupDefaults?.bool(forKey: "focusflow.hasPendingToggle") == true else { return }
        appGroupDefaults?.set(false, forKey: "focusflow.hasPendingToggle")
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    private func runTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                self.tick()
            }
        }
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        let remaining = endDate.timeIntervalSinceNow
        if remaining <= 0 {
            timeRemaining = 0
            completeCurrentPhase(wasSkipped: false)
        } else {
            timeRemaining = remaining
        }
    }

    private func completeCurrentPhase(wasSkipped: Bool) {
        ticker?.cancel()
        isRunning = false
        liveActivityManager.end()
        notificationManager.cancelPendingNotification()

        if phase == .focus, !wasSkipped, let start = sessionStartDate {
            historyStore.record(PomodoroSessionRecord(date: start, duration: totalDuration, phase: .focus))
        }
        if phase == .focus {
            completedFocusSessions += 1
        }

        advancePhase()
        sessionStartDate = nil
        endDate = nil
        timeRemaining = totalDuration

        if settings.autoStartNextPhase {
            start()
        }
    }

    private func advancePhase() {
        switch phase {
        case .focus:
            phase = (completedFocusSessions % settings.sessionsBeforeLongBreak == 0) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            phase = .focus
        }
    }
}
