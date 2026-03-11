import Foundation

struct ReminderSchedule: Codable, Hashable {
    var reminderMinutes: [Int]

    static let dailyDefault = ReminderSchedule(reminderMinutes: [8 * 60])
}
