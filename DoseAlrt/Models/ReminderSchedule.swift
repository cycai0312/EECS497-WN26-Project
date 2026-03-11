import Foundation

nonisolated struct ReminderSchedule: Codable, Hashable, Sendable {
    var reminderMinutes: [Int]

    static let dailyDefault = ReminderSchedule(reminderMinutes: [8 * 60])
}
