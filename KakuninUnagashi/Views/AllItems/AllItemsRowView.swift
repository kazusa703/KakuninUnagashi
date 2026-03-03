import SwiftUI

struct AllItemsRowView: View {
    @Environment(\.appColors) private var colors
    let item: CheckItem

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Text(item.category?.emoji ?? "📋")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(DesignTokens.itemNameFont)
                    .foregroundStyle(colors.primaryText)

                HStack(spacing: 6) {
                    Text(String(localized: "次回: \(DateHelper.formatDate(item.nextDueDate))", comment: "Next due date"))
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(colors.secondaryText)

                    Text("·")
                        .foregroundStyle(colors.secondaryText)

                    Text(item.scheduleDescription)
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(colors.secondaryText)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(colors.secondaryText.opacity(0.5))
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
        .padding(.vertical, DesignTokens.rowVerticalPadding)
        .contentShape(Rectangle())
    }
}
