import SwiftUI

struct EmptyStateView: View {
    @Environment(\.appColors) private var colors
    let icon: String
    let title: String
    let subtitle: String?

    init(icon: String = "checkmark.circle",
         title: String = String(localized: "今日確認が必要な項目はありません", comment: "No items today"),
         subtitle: String? = String(localized: "すべて順調です 👍", comment: "All good"))
    {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(colors.secondaryText.opacity(0.5))

            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(colors.secondaryText.opacity(0.8))
            }
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}
