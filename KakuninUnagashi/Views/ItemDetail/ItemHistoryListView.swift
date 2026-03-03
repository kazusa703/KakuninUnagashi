import SwiftUI

struct ItemHistoryListView: View {
    @Environment(\.appColors) private var colors
    let confirmations: [Confirmation]

    var body: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 0) {
                Text(String(localized: "確認履歴", comment: "Confirmation history"))
                    .font(DesignTokens.categoryHeaderFont)
                    .foregroundStyle(colors.primaryText)
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.vertical, 12)

                SeparatorView()
                    .padding(.horizontal, DesignTokens.horizontalPadding)

                if confirmations.isEmpty {
                    Text(String(localized: "まだ確認履歴がありません", comment: "No history"))
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(colors.secondaryText)
                        .padding(DesignTokens.horizontalPadding)
                } else {
                    ForEach(confirmations, id: \.id) { confirmation in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(colors.confirmedGreen)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(DateHelper.formatDate(confirmation.confirmedAt))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(colors.primaryText)

                                Text(DateHelper.formatTime(confirmation.confirmedAt))
                                    .font(DesignTokens.captionFont)
                                    .foregroundStyle(colors.secondaryText)

                                if let memo = confirmation.memo, !memo.isEmpty {
                                    Text(memo)
                                        .font(DesignTokens.captionFont)
                                        .foregroundStyle(colors.secondaryText)
                                }

                                if let photoData = confirmation.photoData,
                                   let uiImage = UIImage(data: photoData)
                                {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal, DesignTokens.horizontalPadding)
                        .padding(.vertical, 10)

                        if confirmation.id != confirmations.last?.id {
                            SeparatorView()
                                .padding(.leading, DesignTokens.horizontalPadding + 28)
                        }
                    }
                }
            }
        }
    }
}
