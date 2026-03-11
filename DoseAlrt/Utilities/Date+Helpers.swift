import Foundation

extension Date {
    static func from(minutesSinceMidnight: Int, referenceDay: Date = Date()) -> Date {
        let clamped = max(0, min(minutesSinceMidnight, (23 * 60) + 59))
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: referenceDay)
        return calendar.date(byAdding: .minute, value: clamped, to: startOfDay) ?? referenceDay
    }

    var minutesSinceMidnight: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    func shortTimeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }

    func fullDateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
