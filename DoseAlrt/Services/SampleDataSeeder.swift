import Foundation
import SwiftData

@MainActor
enum SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext, notificationManager: NotificationManager) async {
        let descriptor = FetchDescriptor<Medication>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let samples: [Medication] = [
            Medication(
                name: "Lisinopril",
                dosageText: "10 mg tablet",
                frequencyText: "Once daily",
                plainLanguageExplanation: "This medicine helps control blood pressure and supports heart health.",
                reminderSchedule: ReminderSchedule(reminderMinutes: [8 * 60])
            ),
            Medication(
                name: "Metformin",
                dosageText: "500 mg tablet",
                frequencyText: "Twice daily with meals",
                plainLanguageExplanation: "This medicine helps manage blood sugar levels for diabetes.",
                reminderSchedule: ReminderSchedule(reminderMinutes: [8 * 60, 18 * 60])
            ),
            Medication(
                name: "Atorvastatin",
                dosageText: "20 mg tablet",
                frequencyText: "Once daily in evening",
                plainLanguageExplanation: "This medicine helps lower cholesterol to protect heart and blood vessels.",
                reminderSchedule: ReminderSchedule(reminderMinutes: [21 * 60])
            )
        ]

        for medication in samples {
            context.insert(medication)
            await notificationManager.scheduleNotifications(for: medication)
        }

        context.insert(AppUser(name: "Alex (Patient)", role: .patient))
        context.insert(AppUser(name: "Sam (Caregiver)", role: .caregiver))

        try? context.save()
    }
}
