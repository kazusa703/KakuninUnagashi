import Foundation
import WidgetKit

enum WidgetDataProvider {
    static let appGroupID = "group.com.imai.KakuninUnagashi"

    static func updateWidgetData(items: [CheckItem]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Items due today or overdue
        let dueItems = items
            .filter { $0.nextDueDate <= calendar.date(byAdding: .day, value: 1, to: today)! }
            .sorted { $0.nextDueDate < $1.nextDueDate }

        // Count items confirmed today
        let completedTodayCount = items.filter { item in
            item.confirmations.contains { confirmation in
                calendar.isDateInToday(confirmation.confirmedAt)
            }
        }.count

        let totalDueCount = dueItems.count + completedTodayCount

        let widgetItems = dueItems.prefix(6).map { item in
            let dueTime: String? = if let time = item.notificationTime {
                DateHelper.formatTime(time)
            } else {
                nil
            }

            return SharedWidgetItem(
                id: item.id,
                name: item.name,
                emoji: item.category?.emoji ?? "📋",
                categoryColor: item.category?.colorHex ?? "#8E8E93",
                dueStatus: DateHelper.dueStatusText(for: item),
                dueTime: dueTime,
                isOverdue: item.isOverdue,
                isDueToday: item.isDueToday,
                daysUntilDue: item.daysUntilDue
            )
        }

        let data = SharedWidgetData(
            totalDueCount: totalDueCount,
            completedTodayCount: completedTodayCount,
            items: Array(widgetItems)
        )

        guard let defaults = UserDefaults(suiteName: appGroupID),
              let encoded = try? JSONEncoder().encode(data) else { return }

        defaults.set(encoded, forKey: "widgetItems")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Shared data models (must match widget target's SharedWidgetData/SharedWidgetItem)
struct SharedWidgetData: Codable {
    let totalDueCount: Int
    let completedTodayCount: Int
    let items: [SharedWidgetItem]
}

struct SharedWidgetItem: Codable {
    let id: UUID
    let name: String
    let emoji: String
    let categoryColor: String
    let dueStatus: String
    let dueTime: String?
    let isOverdue: Bool
    let isDueToday: Bool
    let daysUntilDue: Int
}
