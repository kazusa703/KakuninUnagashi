import SwiftUI

struct StatusCardView: View {
    @Environment(\.appColors) private var colors
    let item: CheckItem

    var body: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 12) {
                // Next due date
                Text(String(localized: "次回確認日", comment: "Next due date label"))
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(colors.secondaryText)

                HStack {
                    Text(DateHelper.formatDateWithWeekday(item.nextDueDate))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                    Text(DateHelper.dueStatusText(for: item))
                        .font(DesignTokens.daysRemainingFont)
                        .foregroundStyle(dueColor)
                }

                SeparatorView()

                // Schedule info
                HStack {
                    Text(String(localized: "スケジュール", comment: "Schedule label"))
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(colors.secondaryText)
                    Spacer()
                    Text(item.scheduleDescription)
                        .font(.system(size: 15))
                        .foregroundStyle(colors.primaryText)
                }

                // Last confirmation
                if let last = item.lastConfirmation {
                    HStack {
                        Text(String(localized: "前回確認", comment: "Last confirmed label"))
                            .font(DesignTokens.captionFont)
                            .foregroundStyle(colors.secondaryText)
                        Spacer()
                        Text(DateHelper.formatDate(last.confirmedAt))
                            .font(.system(size: 15))
                            .foregroundStyle(colors.primaryText)
                    }
                }
            }
            .padding(DesignTokens.horizontalPadding)
        }
    }

    private var dueColor: Color {
        let days = item.daysUntilDue
        if days < 0 {
            return colors.overdueRed
        } else if days <= 3 {
            return colors.primaryAccent
        } else {
            return colors.secondaryText
        }
    }
}
