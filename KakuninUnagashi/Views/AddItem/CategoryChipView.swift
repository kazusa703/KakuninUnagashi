import SwiftUI

struct CategoryChipView: View {
    @Environment(\.appColors) private var colors
    let category: CheckCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(category.emoji)
                    .font(.system(size: 16))
                Text(category.name)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : colors.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color(hex: category.colorHex)
                    : colors.cardBackground
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : colors.separator,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct CategoryChipRow: View {
    let categories: [CheckCategory]
    @Binding var selectedCategory: CheckCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.id) { category in
                    CategoryChipView(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}
