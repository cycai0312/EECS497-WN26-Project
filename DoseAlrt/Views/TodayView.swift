import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Medication.name) private var medications: [Medication]
    @Query(sort: \DoseLog.timestamp, order: .reverse) private var logs: [DoseLog]

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
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(card.medication.name), \(card.nextReminderText)")

                        HStack(spacing: 10) {
                            PrimaryActionButton(title: "Taken", color: AppTheme.successGreen, systemImage: "checkmark.circle.fill") {
                                logDose(medication: card.medication, status: .taken)
                            }
                            PrimaryActionButton(title: "Skipped", color: AppTheme.dangerRed, systemImage: "xmark.circle.fill") {
                                logDose(medication: card.medication, status: .skipped)
                            }
                            PrimaryActionButton(title: "Maybe Later", color: AppTheme.warningOrange, systemImage: "clock.fill") {
                                logDose(medication: card.medication, status: .maybeLater)
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
    }

    private func logDose(medication: Medication, status: DoseStatus) {
        let repository = LocalMedicationRepository(modelContext: modelContext)
        try? repository.logDose(for: medication, status: status, at: Date())
    }
}
