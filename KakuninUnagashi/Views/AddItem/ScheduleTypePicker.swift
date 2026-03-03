import SwiftUI

struct ScheduleTypePicker: View {
    @Environment(\.appColors) private var colors
    @Binding var scheduleType: ScheduleType
    @Binding var intervalValue: Int
    @Binding var intervalUnit: IntervalUnit
    @Binding var specificDate: Date
    @Binding var repeatYearly: Bool
    @Binding var dayOfWeek: Int
    @Binding var weekOrdinal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Schedule type tabs
            CustomSegmentControl(
                selection: $scheduleType,
                options: ScheduleType.allCases.map { ($0, $0.localizedName) }
            )

            // Type-specific options
            switch scheduleType {
            case .fixedInterval:
                fixedIntervalView
            case .afterCompletion:
                afterCompletionView
            case .specificDate:
                specificDateView
            case .dayOfWeek:
                dayOfWeekView
            }
        }
    }

    // MARK: - Fixed Interval

    private var fixedIntervalView: some View {
        VStack(alignment: .leading, spacing: 8) {
            IntervalPickerView(value: $intervalValue, unit: $intervalUnit)
            Text(String(localized: "カレンダー上の固定スケジュールで繰り返します", comment: "Fixed interval description"))
                .font(DesignTokens.captionFont)
                .foregroundStyle(colors.secondaryText)
        }
    }

    // MARK: - After Completion

    private var afterCompletionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            IntervalPickerView(value: $intervalValue, unit: $intervalUnit)
            Text(String(localized: "実際に確認した日から数え直します", comment: "After completion description"))
                .font(DesignTokens.captionFont)
                .foregroundStyle(colors.secondaryText)
        }
    }

    // MARK: - Specific Date

    private var specificDateView: some View {
        VStack(alignment: .leading, spacing: 12) {
            DatePicker(
                String(localized: "日付", comment: "Date picker label"),
                selection: $specificDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .tint(colors.primaryAccent)

            HStack {
                Text(String(localized: "毎年繰り返し", comment: "Repeat yearly"))
                    .font(.system(size: 16))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Toggle("", isOn: $repeatYearly)
                    .tint(colors.primaryAccent)
                    .labelsHidden()
            }
        }
    }

    // MARK: - Day of Week

    private var dayOfWeekView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Frequency
            HStack(spacing: 8) {
                ForEach([
                    (0, String(localized: "毎週", comment: "Every week")),
                    (1, String(localized: "第1", comment: "1st week")),
                    (2, String(localized: "第2", comment: "2nd week")),
                    (3, String(localized: "第3", comment: "3rd week")),
                    (4, String(localized: "第4", comment: "4th week")),
                ], id: \.0) { ordinal, label in
                    Button {
                        weekOrdinal = ordinal
                    } label: {
                        Text(label)
                            .font(.system(size: 13, weight: weekOrdinal == ordinal ? .semibold : .regular))
                            .foregroundStyle(weekOrdinal == ordinal ? .white : colors.primaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(weekOrdinal == ordinal ? colors.primaryAccent : colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Day of week chips
            let weekdays = Calendar.current.shortWeekdaySymbols
            HStack(spacing: 8) {
                ForEach(0 ..< 7, id: \.self) { index in
                    Button {
                        dayOfWeek = index
                    } label: {
                        Text(weekdays[index])
                            .font(.system(size: 14, weight: dayOfWeek == index ? .semibold : .regular))
                            .foregroundStyle(dayOfWeek == index ? .white : colors.primaryText)
                            .frame(width: 40, height: 40)
                            .background(dayOfWeek == index ? colors.primaryAccent : colors.cardBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
