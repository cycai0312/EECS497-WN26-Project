import Foundation

struct TodayMedicationCardData: Identifiable {
    let id: UUID
    let medication: Medication
    let nextReminderText: String
    let lastStatusText: String
}

@MainActor
enum TodayViewModel {
    static func buildCards(medications: [Medication], logs: [DoseLog], now: Date = Date()) -> [TodayMedicationCardData] {
        medications
            .filter(\.isActive)
            .map { medication in
                let nextReminder = nextReminderText(for: medication, now: now)
                let lastLog = logs
                    .filter { $0.medicationID == medication.id }
                    .sorted { $0.timestamp > $1.timestamp }
                    .first

                let lastStatus: String
                if let lastLog {
                    lastStatus = "Last update: \(lastLog.status.title) at \(lastLog.timestamp.shortTimeString())"
                } else {
                    lastStatus = "No dose logged yet"
                }

                return TodayMedicationCardData(
                    id: medication.id,
                    medication: medication,
                    nextReminderText: nextReminder,
                    lastStatusText: lastStatus
                )
            }
            .sorted { $0.medication.name < $1.medication.name }
    }

    private static func nextReminderText(for medication: Medication, now: Date) -> String {
        let todayMinutesNow = now.minutesSinceMidnight
        let sorted = medication.sortedReminderMinutes

        if let nextToday = sorted.first(where: { $0 >= todayMinutesNow }) {
            let date = Date.from(minutesSinceMidnight: nextToday, referenceDay: now)
            return "Next reminder today at \(date.shortTimeString())"
        }

        if let firstTomorrow = sorted.first {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
            let date = Date.from(minutesSinceMidnight: firstTomorrow, referenceDay: tomorrow)
            return "Next reminder tomorrow at \(date.shortTimeString())"
        }

        return "No reminders set"
    }
}
