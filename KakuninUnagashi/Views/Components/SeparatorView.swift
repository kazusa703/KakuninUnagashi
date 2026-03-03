import SwiftUI

struct SeparatorView: View {
    @Environment(\.appColors) private var colors

    var body: some View {
        colors.separator
            .frame(height: DesignTokens.separatorHeight)
    }
}
