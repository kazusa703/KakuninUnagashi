import Foundation

enum ScheduleCalculator {
    private static let calendar = Calendar.current

    /// Calculate the next due date after confirmation
    static func nextDueDate(for item: CheckItem, confirmedAt: Date = Date()) -> Date {
        switch item.scheduleType {
        case .fixedInterval:
            return nextFixedInterval(from: item.nextDueDate, value: item.intervalValue, unit: item.intervalUnit)
        case .afterCompletion:
            return nextAfterCompletion(from: confirmedAt, value: item.intervalValue, unit: item.intervalUnit)
        case .specificDate:
            return nextSpecificDate(from: item.specificDate, repeatYearly: item.repeatYearly)
        case .dayOfWeek:
            return nextDayOfWeek(dayOfWeek: item.dayOfWeek ?? 1, ordinal: item.weekOrdinal ?? 0, from: confirmedAt)
        }
    }

    /// Calculate the initial due date when creating an item
    static func initialDueDate(
        scheduleType: ScheduleType,
        startDate: Date,
        intervalValue: Int,
        intervalUnit: IntervalUnit,
        specificDate: Date?,
        dayOfWeek: Int?,
        weekOrdinal: Int?
    ) -> Date {
        switch scheduleType {
        case .fixedInterval, .afterCompletion:
            return DateHelper.addingInterval(to: startDate, value: intervalValue, unit: intervalUnit)
        case .specificDate:
            return specificDate ?? startDate
        case .dayOfWeek:
            return nextDayOfWeek(dayOfWeek: dayOfWeek ?? 1, ordinal: weekOrdinal ?? 0, from: startDate)
        }
    }

    // MARK: - Private

    private static func nextFixedInterval(from dueDate: Date, value: Int, unit: IntervalUnit) -> Date {
        DateHelper.addingInterval(to: dueDate, value: value, unit: unit)
    }

    private static func nextAfterCompletion(from completionDate: Date, value: Int, unit: IntervalUnit) -> Date {
        DateHelper.addingInterval(to: completionDate, value: value, unit: unit)
    }

    private static func nextSpecificDate(from date: Date?, repeatYearly: Bool) -> Date {
        guard let date else { return Date() }
        if repeatYearly {
            var components = calendar.dateComponents([.month, .day], from: date)
            let currentYear = calendar.component(.year, from: Date())
            components.year = currentYear
            if let thisYear = calendar.date(from: components), thisYear > Date() {
                return thisYear
            }
            components.year = currentYear + 1
            return calendar.date(from: components) ?? date
        }
        return date
    }

    private static func nextDayOfWeek(dayOfWeek: Int, ordinal: Int, from date: Date) -> Date {
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))!

        if ordinal == 0 {
            // Every week
            return nextWeekday(dayOfWeek, after: startOfTomorrow)
        } else {
            // Nth weekday of month
            return nextNthWeekday(dayOfWeek, ordinal: ordinal, after: startOfTomorrow)
        }
    }

    private static func nextWeekday(_ targetWeekday: Int, after date: Date) -> Date {
        let currentWeekday = calendar.component(.weekday, from: date) - 1 // 0-indexed
        var daysToAdd = targetWeekday - currentWeekday
        if daysToAdd <= 0 { daysToAdd += 7 }
        return calendar.date(byAdding: .day, value: daysToAdd, to: calendar.startOfDay(for: date)) ?? date
    }

    private static func nextNthWeekday(_ targetWeekday: Int, ordinal: Int, after date: Date) -> Date {
        // Try current month first
        if let result = nthWeekdayOfMonth(targetWeekday, ordinal: ordinal, year: calendar.component(.year, from: date), month: calendar.component(.month, from: date)),
           result >= date
        {
            return result
        }
        // Try next month
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: date)!
        return nthWeekdayOfMonth(
            targetWeekday,
            ordinal: ordinal,
            year: calendar.component(.year, from: nextMonth),
            month: calendar.component(.month, from: nextMonth)
        ) ?? date
    }

    private static func nthWeekdayOfMonth(_ targetWeekday: Int, ordinal: Int, year: Int, month: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let firstOfMonth = calendar.date(from: components) else { return nil }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        var daysToAdd = targetWeekday - firstWeekday
        if daysToAdd < 0 { daysToAdd += 7 }
        daysToAdd += (ordinal - 1) * 7

        return calendar.date(byAdding: .day, value: daysToAdd, to: firstOfMonth)
    }
}
