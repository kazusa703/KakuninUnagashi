import Foundation

// MARK: - Schedule Type

enum ScheduleType: String, Codable, CaseIterable {
    case fixedInterval // Fixed interval from due date
    case afterCompletion // Count from completion date
    case specificDate // Specific calendar date
    case dayOfWeek // Day of week based

    var displayNameKey: String {
        switch self {
        case .fixedInterval: return "schedule.fixed"
        case .afterCompletion: return "schedule.afterCompletion"
        case .specificDate: return "schedule.specificDate"
        case .dayOfWeek: return "schedule.dayOfWeek"
        }
    }

    var localizedName: String {
        switch self {
        case .fixedInterval: return String(localized: "定期間隔", comment: "Fixed interval schedule type")
        case .afterCompletion: return String(localized: "完了後カウント", comment: "After completion schedule type")
        case .specificDate: return String(localized: "特定日", comment: "Specific date schedule type")
        case .dayOfWeek: return String(localized: "曜日指定", comment: "Day of week schedule type")
        }
    }
}

// MARK: - Interval Unit

enum IntervalUnit: String, Codable, CaseIterable {
    case day
    case week
    case month
    case year

    var localizedName: String {
        switch self {
        case .day: return String(localized: "日", comment: "Day unit")
        case .week: return String(localized: "週", comment: "Week unit")
        case .month: return String(localized: "月", comment: "Month unit")
        case .year: return String(localized: "年", comment: "Year unit")
        }
    }

    var localizedSuffix: String {
        switch self {
        case .day: return String(localized: "日ごと", comment: "Every N days")
        case .week: return String(localized: "週間ごと", comment: "Every N weeks")
        case .month: return String(localized: "ヶ月ごと", comment: "Every N months")
        case .year: return String(localized: "年ごと", comment: "Every N years")
        }
    }
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable {
    case nextDueDate
    case name
    case category
    case createdAt

    var localizedName: String {
        switch self {
        case .nextDueDate: return String(localized: "次回確認日順", comment: "Sort by next due date")
        case .name: return String(localized: "名前順", comment: "Sort by name")
        case .category: return String(localized: "カテゴリ順", comment: "Sort by category")
        case .createdAt: return String(localized: "作成日順", comment: "Sort by creation date")
        }
    }
}

// MARK: - Home Filter

enum HomeFilter: String, CaseIterable {
    case today
    case thisWeek
    case thisMonth
    case all
    case overdue

    var localizedName: String {
        switch self {
        case .today: return String(localized: "今日", comment: "Today filter")
        case .thisWeek: return String(localized: "今週", comment: "This week filter")
        case .thisMonth: return String(localized: "今月", comment: "This month filter")
        case .all: return String(localized: "全て", comment: "All filter")
        case .overdue: return String(localized: "期限超過", comment: "Overdue filter")
        }
    }
}
