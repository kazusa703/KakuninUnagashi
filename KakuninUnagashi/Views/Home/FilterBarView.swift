import SwiftUI

struct FilterBarView: View {
    @Environment(\.appColors) private var colors
    @Binding var selectedFilter: HomeFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(HomeFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        title: filter.localizedName,
                        isSelected: selectedFilter == filter,
                        accentColor: colors.primaryAccent
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
        }
    }
}

private struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? accentColor : .secondary)

                Rectangle()
                    .fill(isSelected ? accentColor : .clear)
                    .frame(height: DesignTokens.filterUnderlineHeight)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }
}
