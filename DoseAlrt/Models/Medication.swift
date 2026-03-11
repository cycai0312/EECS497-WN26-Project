import Foundation
import SwiftData

@Model
final class Medication {
    @Attribute(.unique) var id: UUID
    var name: String
    var dosageText: String
    var frequencyText: String
    var plainLanguageExplanation: String
    var reminderScheduleData: Data
    var isActive: Bool
    var snoozedUntil: Date?
    var createdAt: Date

    var reminderSchedule: ReminderSchedule {
        get {
            guard let decoded = try? JSONDecoder().decode(ReminderSchedule.self, from: reminderScheduleData) else {
                return .dailyDefault
            }
            return decoded
        }
        set {
            reminderScheduleData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var sortedReminderMinutes: [Int] {
        reminderSchedule.reminderMinutes.sorted()
    }

    init(
        id: UUID = UUID(),
        name: String,
        dosageText: String,
        frequencyText: String,
        plainLanguageExplanation: String,
        reminderSchedule: ReminderSchedule,
        isActive: Bool = true,
        snoozedUntil: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dosageText = dosageText
        self.frequencyText = frequencyText
        self.plainLanguageExplanation = plainLanguageExplanation
        self.reminderScheduleData = (try? JSONEncoder().encode(reminderSchedule)) ?? Data()
        self.isActive = isActive
        self.snoozedUntil = snoozedUntil
        self.createdAt = createdAt
    }
}
