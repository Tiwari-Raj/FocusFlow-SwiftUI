import SwiftUI

struct PhaseBadge: View {
    let phase: PomodoroPhase

    var body: some View {
        Label(phase.title, systemImage: phase.systemImage)
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(phase.accentColor.opacity(0.15), in: Capsule())
            .foregroundStyle(phase.accentColor)
    }
}
