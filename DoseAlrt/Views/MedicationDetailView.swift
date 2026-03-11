import SwiftUI
import SwiftData

struct MedicationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \DoseLog.timestamp, order: .reverse) private var allLogs: [DoseLog]

    let medication: Medication

    private var logs: [DoseLog] {
        allLogs.filter { $0.medicationID == medication.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(medication.name)
                        .font(.system(size: 32, weight: .bold))
                    Text(medication.dosageText)
                        .font(.system(size: 22, weight: .medium))
                    Text(medication.frequencyText)
                        .font(.system(size: 19))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("What this medicine does")
                        .font(.system(size: 22, weight: .bold))
                    Text(medication.plainLanguageExplanation)
                        .font(.system(size: 19))
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Reminder Times")
                        .font(.system(size: 22, weight: .bold))

                    ForEach(medication.sortedReminderMinutes, id: \.self) { minute in
                        Text(Date.from(minutesSinceMidnight: minute).shortTimeString())
                            .font(.system(size: 19))
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Log")
                        .font(.system(size: 22, weight: .bold))

                    HStack(spacing: 12) {
                        PrimaryActionButton(title: "Taken", color: AppTheme.successGreen, systemImage: "checkmark.circle.fill") {
                            Task { await addLog(.taken) }
                        }
                        PrimaryActionButton(title: "Skipped", color: AppTheme.dangerRed, systemImage: "xmark.circle.fill") {
                            Task { await addLog(.skipped) }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent History")
                        .font(.system(size: 22, weight: .bold))

                    if logs.isEmpty {
                        Text("No history yet.")
                            .font(.system(size: 18))
                    } else {
                        ForEach(logs.prefix(10)) { log in
                            HStack {
                                Text(log.status.title)
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                                Text(log.timestamp.fullDateTimeString())
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            .padding(12)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Medication")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addLog(_ status: DoseStatus) async {
        let repository = LocalMedicationRepository(modelContext: modelContext)
        medication.snoozedUntil = nil
        try? repository.logDose(for: medication, status: status, at: Date())
        try? repository.save()
        await notificationManager.removeSnoozeNotifications(for: medication.id)
    }
}
