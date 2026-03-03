import SwiftUI

struct CustomSegmentControl<T: Hashable>: View {
    @Environment(\.appColors) private var colors
    @Binding var selection: T
    let options: [(value: T, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option.value
                    }
                } label: {
                    Text(option.label)
                        .font(.system(size: 14, weight: selection == option.value ? .semibold : .regular))
                        .foregroundStyle(selection == option.value ? .white : colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selection == option.value
                                ? colors.primaryAccent
                                : Color.clear
                        )
                }
                if index < options.count - 1 {
                    colors.separator
                        .frame(width: DesignTokens.separatorHeight)
                }
            }
        }
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
    }
}
