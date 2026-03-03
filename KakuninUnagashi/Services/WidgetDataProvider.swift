import Foundation
import WidgetKit

enum WidgetDataProvider {
    static let appGroupID = "group.com.imai.KakuninUnagashi"

    static func updateWidgetData(items: [CheckItem]) {
        let dueItems = items
            .filter { $0.nextDueDate <= Date() || $0.isDueToday }
            .sorted { $0.nextDueDate < $1.nextDueDate }

        let widgetItems = dueItems.prefix(5).map { item in
            SharedWidgetItem(
                id: item.id,
                name: item.name,
                emoji: item.category?.emoji ?? "📋",
                dueStatus: DateHelper.dueStatusText(for: item),
                isOverdue: item.isOverdue,
                isDueToday: item.isDueToday
            )
        }

        let data = SharedWidgetData(
            uncheckedCount: dueItems.count,
            items: widgetItems
        )

        guard let defaults = UserDefaults(suiteName: appGroupID),
              let encoded = try? JSONEncoder().encode(data) else { return }

        defaults.set(encoded, forKey: "widgetItems")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Shared data models (used by both app and widget)
struct SharedWidgetData: Codable {
    let uncheckedCount: Int
    let items: [SharedWidgetItem]
}

struct SharedWidgetItem: Codable {
    let id: UUID
    let name: String
    let emoji: String
    let dueStatus: String
    let isOverdue: Bool
    let isDueToday: Bool
}
