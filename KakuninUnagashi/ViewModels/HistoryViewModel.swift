import Foundation
import SwiftData

@MainActor
@Observable
final class HistoryViewModel {
    var currentMonth: Date = .init()

    func previousMonth() {
        currentMonth = DateHelper.previousMonth(from: currentMonth)
    }

    func nextMonth() {
        currentMonth = DateHelper.nextMonth(from: currentMonth)
    }

    var monthYearString: String {
        DateHelper.monthYearString(for: currentMonth)
    }

    func filteredConfirmations(from items: [CheckItem]) -> [ConfirmationWithItem] {
        items.flatMap { item in
            item.confirmations
                .filter { DateHelper.isInSameMonth($0.confirmedAt, currentMonth) }
                .map { ConfirmationWithItem(confirmation: $0, item: item) }
        }
        .sorted { $0.confirmation.confirmedAt > $1.confirmation.confirmedAt }
    }

    func groupedByDate(_ confirmations: [ConfirmationWithItem]) -> [(date: Date, entries: [ConfirmationWithItem])] {
        let grouped = Dictionary(grouping: confirmations) { entry in
            DateHelper.startOfDay(entry.confirmation.confirmedAt)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, entries: $0.value) }
    }
}

struct ConfirmationWithItem: Identifiable {
    let confirmation: Confirmation
    let item: CheckItem

    var id: UUID {
        confirmation.id
    }
}
