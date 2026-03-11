import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \Medication.name) private var medications: [Medication]

    @State private var showingAddSheet = false
    @State private var editingMedication: Medication?
    @State private var showingEditSheet = false

    var body: some View {
        List {
            Section {
                ForEach(medications) { medication in
                    NavigationLink(destination: MedicationDetailView(medication: medication)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(medication.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(medication.dosageText)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(AppTheme.secondaryText)
                            Text(reminderSummary(for: medication))
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.actionBlue)
                        }
                        .padding(.vertical, 6)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(medication.name), \(medication.dosageText), \(reminderSummary(for: medication))")
                    }
                    .swipeActions {
                        Button("Edit") {
                            editingMedication = medication
                            showingEditSheet = true
                        }
                            .tint(AppTheme.actionBlue)
                        Button("Delete", role: .destructive) {
                            Task { await deleteMedication(medication) }
                        }
                    }
                }
            } header: {
                Text("Current Medications")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Medications")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Medication", systemImage: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                .accessibilityLabel("Add medication")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                MedicationFormView()
            }
        }
        .sheet(isPresented: $showingEditSheet, onDismiss: { editingMedication = nil }) {
            NavigationStack {
                if let medication = editingMedication {
                    MedicationFormView(editingMedication: medication)
                }
            }
        }
    }

    private func reminderSummary(for medication: Medication) -> String {
        medication.sortedReminderMinutes
            .map { Date.from(minutesSinceMidnight: $0).shortTimeString() }
            .joined(separator: ", ")
    }

    private func deleteMedication(_ medication: Medication) async {
        let repository = LocalMedicationRepository(modelContext: modelContext)
        try? repository.deleteMedication(medication)
        await notificationManager.removeNotifications(for: medication.id)
    }
}
