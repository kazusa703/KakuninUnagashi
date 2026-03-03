import SwiftUI

struct CategoryGroupView: View {
    @Environment(\.appColors) private var colors
    let category: CheckCategory
    let items: [CheckItem]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onConfirm: (CheckItem) -> Void
    let onTapItem: (CheckItem) -> Void
    let confirmingItemID: UUID?
    let confirmationView: (CheckItem) -> AnyView

    var body: some View {
        CustomCardView {
            // Category header
            Button(action: onToggle) {
                HStack {
                    Text(category.emoji)
                        .font(.system(size: 18))
                    Text(category.name)
                        .font(DesignTokens.categoryHeaderFont)
                        .foregroundStyle(colors.primaryText)
                    Text("(\(items.count))")
                        .font(.system(size: 14))
                        .foregroundStyle(colors.secondaryText)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(.horizontal, DesignTokens.horizontalPadding)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            // Items
            if isExpanded {
                SeparatorView()
                    .padding(.horizontal, DesignTokens.horizontalPadding)

                ForEach(items, id: \.id) { item in
                    if confirmingItemID == item.id {
                        confirmationView(item)
                    } else {
                        Button {
                            onTapItem(item)
                        } label: {
                            CheckItemRowView(item: item) {
                                onConfirm(item)
                            }
                        }
                        .buttonStyle(RowHighlightStyle())
                    }

                    if item.id != items.last?.id {
                        SeparatorView()
                            .padding(.leading, DesignTokens.horizontalPadding + 32)
                    }
                }
            }
        }
        .animation(DesignTokens.springAnimation, value: isExpanded)
    }
}

/// FotMob-style row highlight on tap
struct RowHighlightStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.1) : Color.clear)
    }
}
