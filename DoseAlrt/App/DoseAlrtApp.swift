import SwiftUI
import SwiftData

@main
struct DoseAlrtApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Medication.self,
            DoseLog.self,
            AppUser.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.requestAuthorization()
                    await SampleDataSeeder.seedIfNeeded(
                        context: sharedModelContainer.mainContext,
                        notificationManager: notificationManager
                    )
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
