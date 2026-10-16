import SwiftUI

/// Centralized theming so every view and the widget extension agree on
/// what each phase looks like. Add this file to BOTH target memberships.
extension PomodoroPhase {
    var accentColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.95, green: 0.38, blue: 0.38)
        case .shortBreak:
            return Color(red: 0.30, green: 0.75, blue: 0.58)
        case .longBreak:
            return Color(red: 0.36, green: 0.58, blue: 0.93)
        }
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor.opacity(0.85), accentColor.opacity(0.45)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
