import SwiftUI

struct MonthNavigatorView: View {
    @Environment(\.appColors) private var colors
    let monthYearString: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryAccent)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearString)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(colors.primaryText)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryAccent)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
    }
}
