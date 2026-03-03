import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.appColors) private var colors
    @Environment(\.modelContext) private var modelContext

    let notificationManager: NotificationManager
    let storeKitManager: StoreKitManager

    @State private var selectedTab = 0
    @State private var showAddItem = false
    @State private var selectedItem: CheckItem?
    @State private var showItemDetail = false

    @State private var homeVM = HomeViewModel()
    @State private var allItemsVM = AllItemsViewModel()
    @State private var historyVM = HistoryViewModel()
    @State private var settingsVM = SettingsViewModel()

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Tab 1: Home
                HomeView(
                    viewModel: homeVM,
                    notificationManager: notificationManager,
                    storeKitManager: storeKitManager,
                    onAddItem: { showAddItem = true },
                    onTapItem: { item in
                        selectedItem = item
                        showItemDetail = true
                    }
                )
                .tag(0)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(String(localized: "ホーム", comment: "Home tab"))
                }

                // Tab 2: All Items
                AllItemsView(
                    viewModel: allItemsVM,
                    storeKitManager: storeKitManager,
                    onTapItem: { item in
                        selectedItem = item
                        showItemDetail = true
                    }
                )
                .tag(1)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text(String(localized: "全項目", comment: "All items tab"))
                }

                // Tab 3: History
                HistoryView(viewModel: historyVM)
                    .tag(2)
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text(String(localized: "履歴", comment: "History tab"))
                    }

                // Tab 4: Settings
                SettingsView(
                    viewModel: settingsVM,
                    storeKitManager: storeKitManager,
                    notificationManager: notificationManager
                )
                .tag(3)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(String(localized: "設定", comment: "Settings tab"))
                }
            }
            .tint(colors.primaryAccent)
            .navigationDestination(isPresented: $showItemDetail) {
                if let item = selectedItem {
                    ItemDetailView(
                        item: item,
                        viewModel: ItemDetailViewModel(),
                        notificationManager: notificationManager
                    )
                    .withAppTheme()
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemView(
                viewModel: AddItemViewModel(),
                notificationManager: notificationManager
            )
        }
        .task {
            await updateBadge()
        }
    }

    private func updateBadge() async {
        let descriptor = FetchDescriptor<CheckItem>()
        if let items = try? modelContext.fetch(descriptor) {
            let count = items.filter { $0.isOverdue || $0.isDueToday }.count
            await notificationManager.updateBadge(count: count)
            await notificationManager.scheduleNotifications(for: items)
        }
    }
}
