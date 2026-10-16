import Foundation
import Observation

/// Holds every user-configurable preference, persisted to UserDefaults.
/// Using the `@Observable` macro (Swift Observation framework, iOS 17+)
/// instead of `ObservableObject`/`@Published` — views that only read
/// `focusDuration`, for example, won't redraw when `soundEnabled` changes,
/// which is the fine-grained-invalidation win Observation gives us over
/// Combine-based `ObservableObject`.
@Observable
final class SettingsStore {
    var focusDuration: TimeInterval { didSet { persist() } }
    var shortBreakDuration: TimeInterval { didSet { persist() } }
    var longBreakDuration: TimeInterval { didSet { persist() } }
    var sessionsBeforeLongBreak: Int { didSet { persist() } }
    var autoStartNextPhase: Bool { didSet { persist() } }
    var soundEnabled: Bool { didSet { persist() } }
    var hapticsEnabled: Bool { didSet { persist() } }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let focus = "focusflow.settings.focus"
        static let shortBreak = "focusflow.settings.shortBreak"
        static let longBreak = "focusflow.settings.longBreak"
        static let sessions = "focusflow.settings.sessionsBeforeLongBreak"
        static let autoStart = "focusflow.settings.autoStart"
        static let sound = "focusflow.settings.sound"
        static let haptics = "focusflow.settings.haptics"
    }

    init() {
        let d = UserDefaults.standard
        focusDuration = (d.object(forKey: Keys.focus) as? TimeInterval) ?? 25 * 60
        shortBreakDuration = (d.object(forKey: Keys.shortBreak) as? TimeInterval) ?? 5 * 60
        longBreakDuration = (d.object(forKey: Keys.longBreak) as? TimeInterval) ?? 15 * 60
        sessionsBeforeLongBreak = (d.object(forKey: Keys.sessions) as? Int) ?? 4
        autoStartNextPhase = (d.object(forKey: Keys.autoStart) as? Bool) ?? false
        soundEnabled = (d.object(forKey: Keys.sound) as? Bool) ?? true
        hapticsEnabled = (d.object(forKey: Keys.haptics) as? Bool) ?? true
    }

    func resetToDefaults() {
        focusDuration = 25 * 60
        shortBreakDuration = 5 * 60
        longBreakDuration = 15 * 60
        sessionsBeforeLongBreak = 4
        autoStartNextPhase = false
        soundEnabled = true
        hapticsEnabled = true
    }

    private func persist() {
        defaults.set(focusDuration, forKey: Keys.focus)
        defaults.set(shortBreakDuration, forKey: Keys.shortBreak)
        defaults.set(longBreakDuration, forKey: Keys.longBreak)
        defaults.set(sessionsBeforeLongBreak, forKey: Keys.sessions)
        defaults.set(autoStartNextPhase, forKey: Keys.autoStart)
        defaults.set(soundEnabled, forKey: Keys.sound)
        defaults.set(hapticsEnabled, forKey: Keys.haptics)
    }
}
