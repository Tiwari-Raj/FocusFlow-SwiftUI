import SwiftUI

/// Custom `Shape`-free progress ring (a trimmed `Circle` is simpler and
/// just as flexible here). Animates smoothly as `progress` changes.
struct CircularTimerRing: View {
    let progress: Double
    let accentColor: Color
    var lineWidth: CGFloat = 18

    var body: some View {
        ZStack {
            Circle()
                .stroke(accentColor.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session progress")
        .accessibilityValue("\(Int(progress * 100)) percent complete")
    }
}

#Preview {
    CircularTimerRing(progress: 0.4, accentColor: .red)
        .frame(width: 220, height: 220)
        .padding()
}
