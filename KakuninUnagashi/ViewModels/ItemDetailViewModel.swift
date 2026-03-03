import Foundation
import SwiftData

@MainActor
@Observable
final class ItemDetailViewModel {
    var showDeleteConfirmation = false
    var showEditSheet = false

    func confirmItem(_ item: CheckItem, context: ModelContext, notificationManager: NotificationManager) async {
        let confirmation = Confirmation(confirmedAt: Date())
        item.confirmations.append(confirmation)
        item.nextDueDate = ScheduleCalculator.nextDueDate(for: item)
        item.updatedAt = Date()
        try? context.save()

        let descriptor = FetchDescriptor<CheckItem>()
        if let allItems = try? context.fetch(descriptor) {
            await notificationManager.scheduleNotifications(for: allItems)
            let overdueCount = allItems.filter { $0.isOverdue || $0.isDueToday }.count
            await notificationManager.updateBadge(count: overdueCount)
        }
    }

    func deleteItem(_ item: CheckItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }

    var recentConfirmations: (CheckItem) -> [Confirmation] = { item in
        item.confirmations
            .sorted { $0.confirmedAt > $1.confirmedAt }
            .prefix(10)
            .map { $0 }
    }
}
