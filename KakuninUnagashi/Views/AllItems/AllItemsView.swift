import SwiftData
import SwiftUI

struct AllItemsView: View {
    @Environment(\.appColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CheckItem]

    @Bindable var viewModel: AllItemsViewModel
    let storeKitManager: StoreKitManager
    let onTapItem: (CheckItem) -> Void

    @State private var showSortMenu = false

    var body: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Text(String(localized: "全項目", comment: "All items tab"))
                    .font(DesignTokens.navTitleFont)
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.localizedName)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18))
                        .foregroundStyle(colors.primaryAccent)
                }
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 8)

            // Search bar
            CustomSearchBar(text: $viewModel.searchText)
                .padding(.horizontal, DesignTokens.horizontalPadding)
                .padding(.top, 8)

            // Content
            let grouped = viewModel.groupedByCategory(items)

            if grouped.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: String(localized: "項目がありません", comment: "No items"),
                    subtitle: String(localized: "右下の＋ボタンから追加してください", comment: "Add items hint")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(grouped, id: \.category.id) { group in
                            CustomCardView {
                                // Category header
                                Button {
                                    withAnimation(DesignTokens.springAnimation) {
                                        viewModel.toggleCategory(group.category.id)
                                    }
                                } label: {
                                    HStack {
                                        Text(group.category.emoji)
                                            .font(.system(size: 18))
                                        Text(group.category.name)
                                            .font(DesignTokens.categoryHeaderFont)
                                            .foregroundStyle(colors.primaryText)
                                        Text("(\(group.items.count))")
                                            .font(.system(size: 14))
                                            .foregroundStyle(colors.secondaryText)
                                        Spacer()
                                        Image(systemName: viewModel.isCategoryExpanded(group.category.id) ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(colors.secondaryText)
                                    }
                                    .padding(.horizontal, DesignTokens.horizontalPadding)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)

                                if viewModel.isCategoryExpanded(group.category.id) {
                                    SeparatorView()
                                        .padding(.horizontal, DesignTokens.horizontalPadding)

                                    ForEach(group.items, id: \.id) { item in
                                        Button {
                                            onTapItem(item)
                                        } label: {
                                            AllItemsRowView(item: item)
                                        }
                                        .buttonStyle(RowHighlightStyle())
                                        .contextMenu {
                                            Button {
                                                onTapItem(item)
                                            } label: {
                                                Label(String(localized: "編集", comment: "Edit"), systemImage: "pencil")
                                            }
                                            Button(role: .destructive) {
                                                viewModel.deleteItem(item, context: modelContext)
                                            } label: {
                                                Label(String(localized: "削除", comment: "Delete"), systemImage: "trash")
                                            }
                                        }

                                        if item.id != group.items.last?.id {
                                            SeparatorView()
                                                .padding(.leading, DesignTokens.horizontalPadding + 40)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }

            // Ad banner
            AdBannerContainer(storeKitManager: storeKitManager)
        }
        .background(colors.background)
        .onAppear {
            viewModel.initializeExpandedCategories(from: items)
        }
    }
}
