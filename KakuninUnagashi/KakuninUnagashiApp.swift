import GoogleMobileAds
import SwiftData
import SwiftUI

@main
struct KakuninUnagashiApp: App {
    @State private var notificationManager = NotificationManager()
    @State private var storeKitManager = StoreKitManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CheckItem.self,
            Confirmation.self,
            CheckCategory.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                notificationManager: notificationManager,
                storeKitManager: storeKitManager
            )
            .withAppTheme()
            .task {
                await notificationManager.requestAuthorization()
                notificationManager.setupNotificationActions()
                seedDefaultCategories()
                ATTManager.requestTrackingPermission()
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedDefaultCategories() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<CheckCategory>()
        let count = (try? context.fetchCount(descriptor)) ?? 0

        if count == 0 {
            for category in CheckCategory.defaultCategories() {
                context.insert(category)
            }
            try? context.save()
        }
    }
}
