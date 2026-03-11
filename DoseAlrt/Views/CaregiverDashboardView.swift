import SwiftUI
import SwiftData

struct CaregiverDashboardView: View {
    @Query(sort: \Medication.name) private var medications: [Medication]
    @Query(sort: \DoseLog.timestamp, order: .reverse) private var logs: [DoseLog]

    var body: some View {
        let summaries = CaregiverDashboardViewModel.summaries(medications: medications, logs: logs)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Caregiver Dashboard")
                    .font(.system(size: 32, weight: .bold))

                Text("Review today's adherence and quickly spot missed doses.")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.secondaryText)

                if summaries.isEmpty {
                    Text("No medications available.")
                        .font(.system(size: 18, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                ForEach(summaries) { summary in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(summary.medicationName)
                            .font(.system(size: 24, weight: .bold))

                        Text("Taken today: \(summary.takenToday)/\(summary.expectedDosesToday)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.successGreen)

                        Text("Missed today: \(summary.missedToday)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(summary.missedToday > 0 ? AppTheme.dangerRed : AppTheme.secondaryText)

                        Text("Skipped today: \(summary.skippedToday) | Maybe later: \(summary.maybeLaterToday)")
                            .font(.system(size: 17))
                            .foregroundStyle(AppTheme.secondaryText)

                        if let lastTakenAt = summary.lastTakenAt {
                            Text("Last confirmed taken: \(lastTakenAt.fullDateTimeString())")
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.secondaryText)
                        } else {
                            Text("Last confirmed taken: No record yet")
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.system(size: 24, weight: .bold))

                    ForEach(logs.prefix(15)) { log in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.medicationNameSnapshot)
                                    .font(.system(size: 18, weight: .semibold))
                                Text(log.status.title)
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            Spacer()
                            Text(log.timestamp.fullDateTimeString())
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(12)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
