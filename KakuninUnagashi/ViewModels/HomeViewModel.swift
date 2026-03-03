import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var selectedFilter: HomeFilter = .today
    var expandedCategories: Set<UUID> = []
    var confirmingItemID: UUID?
    var showConfirmationOptions: UUID?

    // Confirmation flow state
    var confirmationMemo: String = ""
    var confirmationPhotoData: Data?

    func filteredItems(from items: [CheckItem]) -> [CheckItem] {
        let today = DateHelper.startOfDay()
        switch selectedFilter {
        case .today:
            return items.filter { DateHelper.startOfDay($0.nextDueDate) <= today }
        case .thisWeek:
            let endOfWeek = DateHelper.endOfWeek()
            return items.filter { $0.nextDueDate <= endOfWeek }
        case .thisMonth:
            let endOfMonth = DateHelper.endOfMonth()
            return items.filter { $0.nextDueDate <= endOfMonth }
        case .all:
            return items
        case .overdue:
            return items.filter { $0.isOverdue }
        }
    }

    func groupedByCategory(_ items: [CheckItem]) -> [(category: CheckCategory, items: [CheckItem])] {
        let grouped = Dictionary(grouping: items) { $0.category?.id ?? UUID() }
        return grouped
            .compactMap { _, items -> (category: CheckCategory, items: [CheckItem])? in
                guard let category = items.first?.category else { return nil }
                return (category: category, items: items.sorted { $0.nextDueDate < $1.nextDueDate })
            }
            .sorted { $0.category.sortOrder < $1.category.sortOrder }
    }

    func toggleCategory(_ categoryID: UUID) {
        if expandedCategories.contains(categoryID) {
            expandedCategories.remove(categoryID)
        } else {
            expandedCategories.insert(categoryID)
        }
    }

    func isCategoryExpanded(_ categoryID: UUID) -> Bool {
        expandedCategories.contains(categoryID)
    }

    func confirmItem(_ item: CheckItem, context _: ModelContext) {
        let confirmation = Confirmation(confirmedAt: Date())
        item.confirmations.append(confirmation)
        showConfirmationOptions = item.id
        confirmationMemo = ""
        confirmationPhotoData = nil
    }

    func finalizeConfirmation(
        for item: CheckItem,
        changingInterval _: Bool = false,
        context: ModelContext,
        notificationManager: NotificationManager
    ) async {
        // Add memo and photo to last confirmation
        if let lastConfirmation = item.confirmations.sorted(by: { $0.confirmedAt > $1.confirmedAt }).first {
            if !confirmationMemo.isEmpty {
                lastConfirmation.memo = confirmationMemo
            }
            if let photoData = confirmationPhotoData {
                lastConfirmation.photoData = photoData
            }
        }

        // Calculate next due date
        item.nextDueDate = ScheduleCalculator.nextDueDate(for: item)
        item.updatedAt = Date()

        try? context.save()
        showConfirmationOptions = nil
        confirmationMemo = ""
        confirmationPhotoData = nil

        // Update notifications
        let descriptor = FetchDescriptor<CheckItem>()
        if let allItems = try? context.fetch(descriptor) {
            await notificationManager.scheduleNotifications(for: allItems)
            let overdueCount = allItems.filter { $0.isOverdue || $0.isDueToday }.count
            await notificationManager.updateBadge(count: overdueCount)
        }
    }

    func initializeExpandedCategories(from items: [CheckItem]) {
        if expandedCategories.isEmpty {
            let categoryIDs = Set(items.compactMap { $0.category?.id })
            expandedCategories = categoryIDs
        }
    }
}
