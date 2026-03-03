import SwiftUI

struct IntervalPickerView: View {
    @Environment(\.appColors) private var colors
    @Binding var value: Int
    @Binding var unit: IntervalUnit

    var body: some View {
        HStack(spacing: 12) {
            // Value picker
            HStack(spacing: 0) {
                Button {
                    if value > 1 { value -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryAccent)
                        .frame(width: 36, height: 36)
                }

                Text("\(value)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                    .frame(minWidth: 40)

                Button {
                    if value < 365 { value += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryAccent)
                        .frame(width: 36, height: 36)
                }
            }
            .padding(.horizontal, 4)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))

            // Unit selector
            HStack(spacing: 0) {
                ForEach(IntervalUnit.allCases, id: \.self) { intervalUnit in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            unit = intervalUnit
                        }
                    } label: {
                        Text(intervalUnit.localizedName)
                            .font(.system(size: 14, weight: unit == intervalUnit ? .semibold : .regular))
                            .foregroundStyle(unit == intervalUnit ? .white : colors.primaryText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                unit == intervalUnit
                                    ? colors.primaryAccent
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
        }
    }
}
