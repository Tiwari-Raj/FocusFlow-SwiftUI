import ActivityKit
import Foundation

/// Static + dynamic data describing one Live Activity session.
/// Shared between the app target and the Widget Extension — add this file
/// to BOTH target memberships in Xcode.
struct FocusFlowAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Stored as a raw String (not `PomodoroPhase` directly) because
        /// ActivityKit's ContentState must stay trivially Codable/stable
        /// across app <-> widget-extension process boundaries.
        var phaseRawValue: String
        var endDate: Date
        var sessionNumber: Int
        var isPaused: Bool

        var phase: PomodoroPhase {
            PomodoroPhase(rawValue: phaseRawValue) ?? .focus
        }
    }

    /// Total length of the current phase, used to compute progress.
    var totalDuration: TimeInterval
}
