import Foundation
import SwiftData

@MainActor
@Observable
final class AddItemViewModel {
    var name: String = ""
    var selectedCategory: CheckCategory?
    var scheduleType: ScheduleType = .fixedInterval
    var intervalValue: Int = 1
    var intervalUnit: IntervalUnit = .month
    var specificDate: Date = .init()
    var repeatYearly: Bool = false
    var dayOfWeek: Int = 1 // Monday
    var weekOrdinal: Int = 0 // Every week
    var startDate: Date = .init()
    var notificationTime: Date?
    var memo: String = ""

    var isEditing: Bool = false
    private var editingItem: CheckItem?

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCategory != nil
    }

    func loadItem(_ item: CheckItem) {
        isEditing = true
        editingItem = item
        name = item.name
        selectedCategory = item.category
        scheduleType = item.scheduleType
        intervalValue = item.intervalValue
        intervalUnit = item.intervalUnit
        specificDate = item.specificDate ?? Date()
        repeatYearly = item.repeatYearly
        dayOfWeek = item.dayOfWeek ?? 1
        weekOrdinal = item.weekOrdinal ?? 0
        notificationTime = item.notificationTime
        memo = item.memo ?? ""
    }

    func save(context: ModelContext, notificationManager: NotificationManager) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, let category = selectedCategory else { return }

        if isEditing, let item = editingItem {
            item.name = trimmedName
            item.category = category
            item.scheduleType = scheduleType
            item.intervalValue = intervalValue
            item.intervalUnit = intervalUnit
            item.specificDate = scheduleType == .specificDate ? specificDate : nil
            item.dayOfWeek = scheduleType == .dayOfWeek ? dayOfWeek : nil
            item.weekOrdinal = scheduleType == .dayOfWeek ? weekOrdinal : nil
            item.repeatYearly = repeatYearly
            item.notificationTime = notificationTime
            item.memo = memo.isEmpty ? nil : memo
            item.nextDueDate = ScheduleCalculator.initialDueDate(
                scheduleType: scheduleType,
                startDate: startDate,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                specificDate: scheduleType == .specificDate ? specificDate : nil,
                dayOfWeek: scheduleType == .dayOfWeek ? dayOfWeek : nil,
                weekOrdinal: scheduleType == .dayOfWeek ? weekOrdinal : nil
            )
            item.updatedAt = Date()
        } else {
            let dueDate = ScheduleCalculator.initialDueDate(
                scheduleType: scheduleType,
                startDate: startDate,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                specificDate: scheduleType == .specificDate ? specificDate : nil,
                dayOfWeek: scheduleType == .dayOfWeek ? dayOfWeek : nil,
                weekOrdinal: scheduleType == .dayOfWeek ? weekOrdinal : nil
            )

            let item = CheckItem(
                name: trimmedName,
                category: category,
                scheduleType: scheduleType,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                specificDate: scheduleType == .specificDate ? specificDate : nil,
                dayOfWeek: scheduleType == .dayOfWeek ? dayOfWeek : nil,
                weekOrdinal: scheduleType == .dayOfWeek ? weekOrdinal : nil,
                repeatYearly: repeatYearly,
                nextDueDate: dueDate,
                notificationTime: notificationTime,
                memo: memo.isEmpty ? nil : memo
            )
            context.insert(item)
        }

        try? context.save()

        // Refresh notifications
        let descriptor = FetchDescriptor<CheckItem>()
        if let allItems = try? context.fetch(descriptor) {
            await notificationManager.scheduleNotifications(for: allItems)
        }
    }

    func reset() {
        name = ""
        selectedCategory = nil
        scheduleType = .fixedInterval
        intervalValue = 1
        intervalUnit = .month
        specificDate = Date()
        repeatYearly = false
        dayOfWeek = 1
        weekOrdinal = 0
        startDate = Date()
        notificationTime = nil
        memo = ""
        isEditing = false
        editingItem = nil
    }
}
