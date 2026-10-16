import SwiftUI

/// Small dot row showing progress toward the next long break.
struct SessionDotsView: View {
    let completed: Int
    let total: Int
    let accentColor: Color

    private var filledCount: Int {
        guard total > 0 else { return 0 }
        let remainder = completed % total
        return (completed > 0 && remainder == 0) ? total : remainder
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Circle()
                    .fill(index < filledCount ? accentColor : accentColor.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}
