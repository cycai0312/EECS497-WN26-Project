import Foundation

@MainActor
final class MedicationFormViewModel: ObservableObject {
    @Published var name: String
    @Published var dosageText: String
    @Published var frequencyText: String
    @Published var plainLanguageExplanation: String
    @Published var reminderTimes: [Date]

    let editingMedication: Medication?

    init(medication: Medication? = nil) {
        self.editingMedication = medication
        self.name = medication?.name ?? ""
        self.dosageText = medication?.dosageText ?? ""
        self.frequencyText = medication?.frequencyText ?? "Once daily"
        self.plainLanguageExplanation = medication?.plainLanguageExplanation ?? ""

        let minutes = medication?.sortedReminderMinutes ?? [8 * 60]
        self.reminderTimes = minutes.map { Date.from(minutesSinceMidnight: $0) }
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !dosageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !frequencyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !plainLanguageExplanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !reminderTimes.isEmpty
    }

    var reminderMinutes: [Int] {
        Array(Set(reminderTimes.map(\.minutesSinceMidnight))).sorted()
    }

    func addReminderTime() {
        reminderTimes.append(Date.from(minutesSinceMidnight: 12 * 60))
    }

    func removeReminderTime(at offsets: IndexSet) {
        reminderTimes.remove(atOffsets: offsets)
        if reminderTimes.isEmpty {
            reminderTimes = [Date.from(minutesSinceMidnight: 8 * 60)]
        }
    }
}
