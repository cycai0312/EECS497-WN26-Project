import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \Medication.name) private var medications: [Medication]
    @Query(sort: \DoseLog.timestamp, order: .reverse) private var logs: [DoseLog]
    @State private var selectedMedicationForSnooze: Medication?
    @State private var showingSnoozeDialog = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)

                Text("Tap a button after each reminder to keep your medication record up to date.")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.secondaryText)

                ForEach(TodayViewModel.buildCards(medications: medications, logs: logs)) { card in
                    VStack(alignment: .leading, spacing: 12) {
                        NavigationLink(destination: MedicationDetailView(medication: card.medication)) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(card.medication.name)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(AppTheme.primaryText)
                                    Text(card.medication.dosageText)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(AppTheme.secondaryText)
                                    Text(card.nextReminderText)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(AppTheme.actionBlue)
                                    Text(card.lastStatusText)
                                        .font(.system(size: 16))
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                                Spacer()
                                adherenceCircle(
                                    completed: card.completedDoseCountToday,
                                    total: card.expectedDoseCountToday
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(card.medication.name), \(card.nextReminderText)")

                        if card.showActionButtons {
                            HStack(spacing: 10) {
                                PrimaryActionButton(title: "Taken", color: AppTheme.successGreen, systemImage: "checkmark.circle.fill") {
                                    Task { await confirmDose(medication: card.medication, status: .taken) }
                                }
                                PrimaryActionButton(title: "Skipped", color: AppTheme.dangerRed, systemImage: "xmark.circle.fill") {
                                    Task { await confirmDose(medication: card.medication, status: .skipped) }
                                }
                                PrimaryActionButton(title: "Maybe Later", color: AppTheme.warningOrange, systemImage: "clock.fill") {
                                    selectedMedicationForSnooze = card.medication
                                    showingSnoozeDialog = true
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .confirmationDialog(
            "Remind me again in...",
            isPresented: $showingSnoozeDialog,
            titleVisibility: .visible
        ) {
            Button("15 minutes") { Task { await snoozeMedication(minutes: 15) } }
            Button("30 minutes") { Task { await snoozeMedication(minutes: 30) } }
            Button("1 hour") { Task { await snoozeMedication(minutes: 60) } }
            Button("Cancel", role: .cancel) {
                selectedMedicationForSnooze = nil
            }
        }
    }

    private func adherenceCircle(completed: Int, total: Int) -> some View {
        let isComplete = total > 0 && completed >= total
        return ZStack {
            Circle()
                .fill(isComplete ? AppTheme.successGreen : AppTheme.dangerRed)
                .frame(width: 64, height: 64)
            Text("\(completed)/\(total)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
        }
        .accessibilityLabel("Today progress \(completed) out of \(total)")
    }

    private func confirmDose(medication: Medication, status: DoseStatus) async {
        let repository = LocalMedicationRepository(modelContext: modelContext)
        medication.snoozedUntil = nil
        try? repository.logDose(for: medication, status: status, at: Date())
        try? repository.save()
        await notificationManager.removeSnoozeNotifications(for: medication.id)
    }

    private func snoozeMedication(minutes: Int) async {
        guard let medication = selectedMedicationForSnooze else { return }
        let repository = LocalMedicationRepository(modelContext: modelContext)

        medication.snoozedUntil = Calendar.current.date(byAdding: .minute, value: minutes, to: Date())
        try? repository.logDose(for: medication, status: .maybeLater, at: Date())
        try? repository.save()

        await notificationManager.scheduleSnoozeNotification(for: medication, afterMinutes: minutes)
        selectedMedicationForSnooze = nil
    }
}
