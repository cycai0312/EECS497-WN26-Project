import SwiftUI
import SwiftData

struct MedicationFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager

    @StateObject private var viewModel: MedicationFormViewModel

    init(editingMedication: Medication? = nil) {
        _viewModel = StateObject(wrappedValue: MedicationFormViewModel(medication: editingMedication))
    }

    var body: some View {
        Form {
            Section("Medication") {
                TextField("Name (e.g., Lisinopril)", text: $viewModel.name)
                    .font(.system(size: 18))
                    .accessibilityLabel("Medication name")

                TextField("Dosage (e.g., 10 mg tablet)", text: $viewModel.dosageText)
                    .font(.system(size: 18))
                    .accessibilityLabel("Dosage")

                TextField("Frequency (e.g., Once daily)", text: $viewModel.frequencyText)
                    .font(.system(size: 18))
                    .accessibilityLabel("Frequency")
            }

            Section("Reminder Times") {
                ForEach(Array(viewModel.reminderTimes.enumerated()), id: \.offset) { index, _ in
                    DatePicker(
                        "Reminder \(index + 1)",
                        selection: Binding(
                            get: { viewModel.reminderTimes[index] },
                            set: { viewModel.reminderTimes[index] = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .font(.system(size: 18))
                }
                .onDelete(perform: viewModel.removeReminderTime)

                Button {
                    viewModel.addReminderTime()
                } label: {
                    Label("Add Another Time", systemImage: "plus.circle")
                        .font(.system(size: 18, weight: .semibold))
                }
            }

            Section("Plain Explanation") {
                TextEditor(text: $viewModel.plainLanguageExplanation)
                    .font(.system(size: 18))
                    .frame(minHeight: 140)
                    .accessibilityLabel("Simple medication explanation")
            }

            Section {
                Text("Use simple language. Example: This medicine helps control blood pressure.")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .navigationTitle(viewModel.editingMedication == nil ? "Add Medication" : "Edit Medication")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .font(.system(size: 18, weight: .semibold))
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await saveMedication() }
                }
                .disabled(!viewModel.isValid)
                .font(.system(size: 18, weight: .bold))
            }
        }
    }

    private func saveMedication() async {
        var medicationToSchedule: Medication?

        if let medication = viewModel.editingMedication {
            medication.name = viewModel.name
            medication.dosageText = viewModel.dosageText
            medication.frequencyText = viewModel.frequencyText
            medication.plainLanguageExplanation = viewModel.plainLanguageExplanation
            medication.reminderSchedule = ReminderSchedule(reminderMinutes: viewModel.reminderMinutes)
            medicationToSchedule = medication
        } else {
            let newMedication = Medication(
                name: viewModel.name,
                dosageText: viewModel.dosageText,
                frequencyText: viewModel.frequencyText,
                plainLanguageExplanation: viewModel.plainLanguageExplanation,
                reminderSchedule: ReminderSchedule(reminderMinutes: viewModel.reminderMinutes)
            )
            modelContext.insert(newMedication)
            medicationToSchedule = newMedication
        }

        try? modelContext.save()

        if let medication = medicationToSchedule {
            await notificationManager.scheduleNotifications(for: medication)
        }

        dismiss()
    }
}
