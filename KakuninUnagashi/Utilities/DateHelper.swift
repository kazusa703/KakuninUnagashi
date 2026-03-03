import Foundation

enum DateHelper {
    private static let calendar = Calendar.current

    // MARK: - Display

    static func dueStatusText(for item: CheckItem) -> String {
        let days = item.daysUntilDue
        if days < 0 {
            return String(localized: "\(abs(days))日超過", comment: "N days overdue")
        } else if days == 0 {
            return String(localized: "今日", comment: "Today")
        } else {
            return String(localized: "あと\(days)日", comment: "N days left")
        }
    }

    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    static func formatDateWithWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMdEEEE",
            options: 0,
            locale: Locale.current
        )
        return formatter.string(from: date)
    }

    static func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "yyyyMMMM",
            options: 0,
            locale: Locale.current
        )
        return formatter.string(from: date)
    }

    // MARK: - Date Calculations

    static func startOfDay(_ date: Date = Date()) -> Date {
        calendar.startOfDay(for: date)
    }

    static func endOfDay(_ date: Date = Date()) -> Date {
        calendar.date(byAdding: .day, value: 1, to: startOfDay(date))!.addingTimeInterval(-1)
    }

    static func endOfWeek(_ date: Date = Date()) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysToEnd = 7 - weekday
        return endOfDay(calendar.date(byAdding: .day, value: daysToEnd, to: date)!)
    }

    static func endOfMonth(_ date: Date = Date()) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        return nextMonth.addingTimeInterval(-1)
    }

    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        calendar.dateComponents([.day], from: startOfDay(from), to: startOfDay(to)).day ?? 0
    }

    static func addingInterval(to date: Date, value: Int, unit: IntervalUnit) -> Date {
        let component: Calendar.Component
        switch unit {
        case .day: component = .day
        case .week: component = .weekOfYear
        case .month: component = .month
        case .year: component = .year
        }
        return calendar.date(byAdding: component, value: value, to: date) ?? date
    }

    // MARK: - Grouping Helpers

    static func groupedByDate<T>(_ items: [T], keyPath: KeyPath<T, Date>) -> [(date: Date, items: [T])] {
        let grouped = Dictionary(grouping: items) { item in
            startOfDay(item[keyPath: keyPath])
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, items: $0.value) }
    }

    static func previousMonth(from date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }

    static func nextMonth(from date: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }

    static func isInSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        let c1 = calendar.dateComponents([.year, .month], from: date1)
        let c2 = calendar.dateComponents([.year, .month], from: date2)
        return c1.year == c2.year && c1.month == c2.month
    }
}
