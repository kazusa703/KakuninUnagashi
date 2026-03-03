import SwiftUI

struct CheckItemRowView: View {
    @Environment(\.appColors) private var colors
    let item: CheckItem
    let onConfirm: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Item info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(DesignTokens.itemNameFont)
                    .foregroundStyle(colors.primaryText)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                    Text(statusText)
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(statusColor)
                }
            }

            Spacer()

            // Days remaining
            Text(DateHelper.dueStatusText(for: item))
                .font(DesignTokens.daysRemainingFont)
                .foregroundStyle(statusColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Confirm button
            ConfirmButton(action: onConfirm)
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
        .padding(.vertical, DesignTokens.rowVerticalPadding)
        .contentShape(Rectangle())
    }

    private var statusText: String {
        let days = item.daysUntilDue
        if days < 0 {
            return DateHelper.formatDate(item.nextDueDate)
        } else if days == 0 {
            return String(localized: "今日が期日です", comment: "Due today")
        } else {
            return String(localized: "期日: \(DateHelper.formatDate(item.nextDueDate))", comment: "Due date label")
        }
    }

    private var statusColor: Color {
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
