import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    @Published private(set) var authorizationGranted = false

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        do {
            authorizationGranted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            authorizationGranted = false
        }
    }

    func scheduleNotifications(for medication: Medication) async {
        await removeNotifications(for: medication.id)

        for minute in medication.sortedReminderMinutes {
            let hour = minute / 60
            let minutePart = minute % 60

            let content = UNMutableNotificationContent()
            content.title = medication.name
            content.body = "Time to take your medication. \(medication.dosageText)."
            content.sound = .default
            content.userInfo = ["medicationID": medication.id.uuidString]

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minutePart

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = notificationIdentifier(medicationID: medication.id, minute: minute)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                // For MVP we silently continue so one bad reminder does not block the rest.
            }
        }
    }

    func removeNotifications(for medicationID: UUID) async {
        let pending = await pendingRequests()
        let regularPrefix = "dosealrt.medication.\(medicationID.uuidString)."
        let snoozePrefix = "dosealrt.snooze.\(medicationID.uuidString)."
        let ids = pending.map(\.identifier).filter {
            $0.hasPrefix(regularPrefix) || $0.hasPrefix(snoozePrefix)
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func rescheduleAll(medications: [Medication]) async {
        center.removeAllPendingNotificationRequests()
        for medication in medications where medication.isActive {
            await scheduleNotifications(for: medication)
        }
    }

    private func notificationIdentifier(medicationID: UUID, minute: Int) -> String {
        "dosealrt.medication.\(medicationID.uuidString).\(minute)"
    }

    func scheduleSnoozeNotification(for medication: Medication, at date: Date) async {
        await removeSnoozeNotifications(for: medication.id)

        let content = UNMutableNotificationContent()
        content.title = medication.name
        content.body = "Reminder again: Time to take your medication."
        content.sound = .default
        content.userInfo = ["medicationID": medication.id.uuidString, "isSnooze": true]

        let interval = max(60, date.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: false
        )

        let identifier = "dosealrt.snooze.\(medication.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func removeSnoozeNotifications(for medicationID: UUID) async {
        let pending = await pendingRequests()
        let prefix = "dosealrt.snooze.\(medicationID.uuidString)"
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
}
