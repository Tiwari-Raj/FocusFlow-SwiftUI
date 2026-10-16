import Foundation

/// A single completed focus session, persisted for the History tab.
struct PomodoroSessionRecord: Codable, Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var duration: TimeInterval
    var phase: PomodoroPhase
}
