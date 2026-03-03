import SwiftUI

struct PrimaryButton: View {
    @Environment(\.appColors) private var colors
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(colors.primaryAccent)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
        }
    }
}

struct CompactButton: View {
    @Environment(\.appColors) private var colors
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(colors.primaryAccent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(colors.primaryAccent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
        }
    }
}

struct ConfirmButton: View {
    @Environment(\.appColors) private var colors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(String(localized: "確認済み", comment: "Confirm button"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(colors.primaryAccent)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
        }
    }
}
