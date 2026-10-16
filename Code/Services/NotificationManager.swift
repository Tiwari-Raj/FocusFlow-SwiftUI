import Foundation
import UserNotifications

/// Local notification backup for when a phase ends while the user isn't
/// looking at the Lock Screen / Dynamic Island.
final class NotificationManager {
    private let center = UNUserNotificationCenter.current()
    private let pendingIdentifier = "focusflow.phase.end"

    func requestAuthorizationIfNeeded() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleEndNotification(for phase: PomodoroPhase, at date: Date) {
        cancelPendingNotification()

        let content = UNMutableNotificationContent()
        content.title = phase == .focus ? "Focus session complete" : "Break's over"
        content.body = phase == .focus ? "Nice work. Time for a break." : "Ready to get back to it?"
        content.sound = .default

        let interval = max(date.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: pendingIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelPendingNotification() {
        center.removePendingNotificationRequests(withIdentifiers: [pendingIdentifier])
    }
}
