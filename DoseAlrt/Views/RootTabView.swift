import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "sun.max")
            }

            NavigationStack {
                MedicationListView()
            }
            .tabItem {
                Label("Medications", systemImage: "pills")
            }

            NavigationStack {
                CaregiverDashboardView()
            }
            .tabItem {
                Label("Caregiver", systemImage: "person.2")
            }
        }
        .tint(AppTheme.actionBlue)
    }
}
