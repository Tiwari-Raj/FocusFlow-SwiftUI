import Foundation
import ActivityKit

/// Thin wrapper around ActivityKit so `TimerViewModel` never touches
/// `Activity<FocusFlowAttributes>` directly. Keeping this isolated also
/// makes it trivial to no-op on devices/OS versions where Live Activities
/// aren't available.
@MainActor
final class LiveActivityManager {
    private var activity: Activity<FocusFlowAttributes>?

    var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(phase: PomodoroPhase, endDate: Date, sessionNumber: Int, totalDuration: TimeInterval) {
        guard isAvailable else { return }
        end() // make sure we never have two live activities running at once

        let attributes = FocusFlowAttributes(totalDuration: totalDuration)
        let state = FocusFlowAttributes.ContentState(
            phaseRawValue: phase.rawValue,
            endDate: endDate,
            sessionNumber: sessionNumber,
            isPaused: false
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil // local-only; pass .token if you add remote push updates later
            )
        } catch {
            print("FocusFlow: failed to start Live Activity — \(error.localizedDescription)")
        }
    }

    func update(phase: PomodoroPhase, endDate: Date?, remaining: TimeInterval, sessionNumber: Int, totalDuration: TimeInterval, isPaused: Bool) {
        guard let activity else { return }
        // When paused there's no real "end date" countdown, so we synthesize
        // one from the remaining time purely so the ContentState type stays simple.
        let resolvedEndDate = endDate ?? Date().addingTimeInterval(remaining)

        let state = FocusFlowAttributes.ContentState(
            phaseRawValue: phase.rawValue,
            endDate: resolvedEndDate,
            sessionNumber: sessionNumber,
            isPaused: isPaused
        )

        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        guard let activity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}
