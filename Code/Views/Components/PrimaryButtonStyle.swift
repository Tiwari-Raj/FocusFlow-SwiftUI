import SwiftUI

/// Reusable custom `ButtonStyle` — demonstrates styling buttons the
/// idiomatic SwiftUI way instead of ad-hoc modifiers everywhere.
struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(tint.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static func primary(tint: Color = .accentColor) -> PrimaryButtonStyle {
        PrimaryButtonStyle(tint: tint)
    }
}
