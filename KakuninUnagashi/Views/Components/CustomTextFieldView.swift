import SwiftUI

struct CustomTextField: View {
    @Environment(\.appColors) private var colors
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        TextField(placeholder, text: $text, axis: axis)
            .font(.system(size: 16))
            .padding(DesignTokens.rowVerticalPadding)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
    }
}

struct CustomSearchBar: View {
    @Environment(\.appColors) private var colors
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(colors.secondaryText)
                .font(.system(size: 16))
            TextField(String(localized: "検索", comment: "Search placeholder"), text: $text)
                .font(.system(size: 16))
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(colors.secondaryText)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
    }
}
