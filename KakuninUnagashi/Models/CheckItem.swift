import Foundation
import SwiftData

@Model
final class CheckItem {
    var id: UUID
    var name: String
    var category: CheckCategory?
    var scheduleTypeRaw: String
    var intervalValue: Int
    var intervalUnitRaw: String
    var specificDate: Date?
    var dayOfWeek: Int? // 0=Sun, 1=Mon, ..., 6=Sat
    var weekOrdinal: Int? // Nth week (1-5, 0=every week)
    var repeatYearly: Bool
    var nextDueDate: Date
    var notificationTime: Date?
    var memo: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var confirmations: [Confirmation] = []

    /// Computed accessors for enums
    var scheduleType: ScheduleType {
        get { ScheduleType(rawValue: scheduleTypeRaw) ?? .fixedInterval }
        set { scheduleTypeRaw = newValue.rawValue }
    }

    var intervalUnit: IntervalUnit {
        get { IntervalUnit(rawValue: intervalUnitRaw) ?? .day }
        set { intervalUnitRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: CheckCategory? = nil,
        scheduleType: ScheduleType = .fixedInterval,
        intervalValue: Int = 1,
        intervalUnit: IntervalUnit = .month,
        specificDate: Date? = nil,
        dayOfWeek: Int? = nil,
        weekOrdinal: Int? = nil,
        repeatYearly: Bool = false,
        nextDueDate: Date = Date(),
        notificationTime: Date? = nil,
        memo: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        scheduleTypeRaw = scheduleType.rawValue
        self.intervalValue = intervalValue
        intervalUnitRaw = intervalUnit.rawValue
        self.specificDate = specificDate
        self.dayOfWeek = dayOfWeek
        self.weekOrdinal = weekOrdinal
        self.repeatYearly = repeatYearly
        self.nextDueDate = nextDueDate
        self.notificationTime = notificationTime
        self.memo = memo
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    var isOverdue: Bool {
        Calendar.current.startOfDay(for: nextDueDate) < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        Calendar.current.isDateInToday(nextDueDate)
    }

    var daysUntilDue: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let due = Calendar.current.startOfDay(for: nextDueDate)
        return Calendar.current.dateComponents([.day], from: today, to: due).day ?? 0
    }

    var lastConfirmation: Confirmation? {
        confirmations.sorted { $0.confirmedAt > $1.confirmedAt }.first
    }

    var scheduleDescription: String {
        switch scheduleType {
        case .fixedInterval, .afterCompletion:
            return "\(intervalValue)\(intervalUnit.localizedSuffix)"
        case .specificDate:
            if let date = specificDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
            return ""
        case .dayOfWeek:
            return dayOfWeekDescription
        }
    }

    private var dayOfWeekDescription: String {
        guard let dow = dayOfWeek else { return "" }
        let symbols = Calendar.current.shortWeekdaySymbols
        let dayName = symbols[dow]

        if let ordinal = weekOrdinal, ordinal > 0 {
            return String(localized: "毎月第\(ordinal)\(dayName)", comment: "Monthly Nth weekday")
        } else {
            return String(localized: "毎週\(dayName)", comment: "Every weekday")
        }
    }
}
