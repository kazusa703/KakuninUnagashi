import SwiftUI

struct CustomCardView<Content: View>: View {
    @Environment(\.appColors) private var colors
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
    }
}
