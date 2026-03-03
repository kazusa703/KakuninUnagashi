import SwiftUI

struct HistoryEntryView: View {
    @Environment(\.appColors) private var colors
    let entry: ConfirmationWithItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Check icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(colors.confirmedGreen)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.item.name)
                        .font(DesignTokens.itemNameFont)
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                    Text(DateHelper.formatTime(entry.confirmation.confirmedAt))
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(colors.secondaryText)
                }

                if let category = entry.item.category {
                    CategoryBadgeView(category: category)
                }

                if let memo = entry.confirmation.memo, !memo.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.system(size: 12))
                            .foregroundStyle(colors.secondaryText)
                        Text(memo)
                            .font(DesignTokens.captionFont)
                            .foregroundStyle(colors.secondaryText)
                            .lineLimit(2)
                    }
                }

                if let photoData = entry.confirmation.photoData,
                   let uiImage = UIImage(data: photoData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
        .padding(.vertical, 10)
    }
}
