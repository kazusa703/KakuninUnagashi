import Foundation
import SwiftData

@MainActor
@Observable
final class AllItemsViewModel {
    var searchText: String = ""
    var sortOption: SortOption = .nextDueDate
    var expandedCategories: Set<UUID> = []

    func filteredItems(from items: [CheckItem]) -> [CheckItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func sortedItems(_ items: [CheckItem]) -> [CheckItem] {
        switch sortOption {
        case .nextDueDate:
            return items.sorted { $0.nextDueDate < $1.nextDueDate }
        case .name:
            return items.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .category:
            return items.sorted { ($0.category?.sortOrder ?? 0) < ($1.category?.sortOrder ?? 0) }
        case .createdAt:
            return items.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func groupedByCategory(_ items: [CheckItem]) -> [(category: CheckCategory, items: [CheckItem])] {
        let filtered = filteredItems(from: items)
        let sorted = sortedItems(filtered)
        let grouped = Dictionary(grouping: sorted) { $0.category?.id ?? UUID() }
        return grouped
            .compactMap { _, items -> (category: CheckCategory, items: [CheckItem])? in
                guard let category = items.first?.category else { return nil }
                return (category: category, items: items)
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

    func initializeExpandedCategories(from items: [CheckItem]) {
        if expandedCategories.isEmpty {
            expandedCategories = Set(items.compactMap { $0.category?.id })
        }
    }

    func deleteItem(_ item: CheckItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }
}
