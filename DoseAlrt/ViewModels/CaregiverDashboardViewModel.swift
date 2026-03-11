import Foundation

struct MedicationDailySummary: Identifiable {
    let id: UUID
    let medicationName: String
    let expectedDosesToday: Int
    let takenToday: Int
    let skippedToday: Int
    let maybeLaterToday: Int
    let missedToday: Int
    let lastTakenAt: Date?
}

@MainActor
enum CaregiverDashboardViewModel {
    static func summaries(medications: [Medication], logs: [DoseLog], now: Date = Date()) -> [MedicationDailySummary] {
        let todayLogs = logs.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: now) }

        return medications.map { medication in
            let medLogsAll = logs.filter { $0.medicationID == medication.id }
            let medLogsToday = todayLogs.filter { $0.medicationID == medication.id }

            let expected = max(1, medication.sortedReminderMinutes.count)
            let taken = medLogsToday.filter { $0.status == .taken }.count
            let skipped = medLogsToday.filter { $0.status == .skipped }.count
            let maybeLater = medLogsToday.filter { $0.status == .maybeLater }.count
            let completed = taken + skipped
            let missed = max(0, expected - completed)
            let lastTaken = medLogsAll
                .filter { $0.status == .taken }
                .sorted { $0.timestamp > $1.timestamp }
                .first?
                .timestamp

            return MedicationDailySummary(
                id: medication.id,
                medicationName: medication.name,
                expectedDosesToday: expected,
                takenToday: taken,
                skippedToday: skipped,
                maybeLaterToday: maybeLater,
                missedToday: missed,
                lastTakenAt: lastTaken
            )
        }
        .sorted { $0.medicationName < $1.medicationName }
    }
}
