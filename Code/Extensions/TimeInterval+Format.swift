import Foundation

extension TimeInterval {
    /// Formats a duration as "MM:SS", clamped to zero.
    var mmss: String {
        let total = max(0, Int(self.rounded()))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
