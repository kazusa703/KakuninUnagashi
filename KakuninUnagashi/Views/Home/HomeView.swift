import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.appColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CheckItem]

    @Bindable var viewModel: HomeViewModel
    let notificationManager: NotificationManager
    let storeKitManager: StoreKitManager
    let onAddItem: () -> Void
    let onTapItem: (CheckItem) -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Navigation header
                HStack {
                    Text(String(localized: "確認促し", comment: "App name"))
                        .font(DesignTokens.navTitleFont)
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.horizontalPadding)
                .padding(.top, 8)

                // Filter bar
                FilterBarView(selectedFilter: $viewModel.selectedFilter)
                    .padding(.top, 8)

                // Content
                let filteredItems = viewModel.filteredItems(from: items)
                let grouped = viewModel.groupedByCategory(filteredItems)

                if grouped.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(grouped, id: \.category.id) { group in
                                CategoryGroupView(
                                    category: group.category,
                                    items: group.items,
                                    isExpanded: viewModel.isCategoryExpanded(group.category.id),
                                    onToggle: { viewModel.toggleCategory(group.category.id) },
                                    onConfirm: { item in
                                        withAnimation(DesignTokens.springAnimation) {
                                            viewModel.confirmItem(item, context: modelContext)
                                        }
                                    },
                                    onTapItem: { item in
                                        onTapItem(item)
                                    },
                                    confirmingItemID: viewModel.showConfirmationOptions,
                                    confirmationView: { item in
                                        AnyView(
                                            ConfirmationInlineView(
                                                item: item,
                                                memo: $viewModel.confirmationMemo,
                                                photoData: $viewModel.confirmationPhotoData,
                                                onDismiss: {
                                                    withAnimation {
                                                        viewModel.showConfirmationOptions = nil
                                                    }
                                                },
                                                onFinalize: {
                                                    Task {
                                                        await viewModel.finalizeConfirmation(
                                                            for: item,
                                                            context: modelContext,
                                                            notificationManager: notificationManager
                                                        )
                                                    }
                                                }
                                            )
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, DesignTokens.horizontalPadding)
                        .padding(.top, 12)
                        .padding(.bottom, 80)
                    }
                }

                // Ad banner
                AdBannerContainer(storeKitManager: storeKitManager)
            }
            .background(colors.background)

            // FAB
            Button(action: onAddItem) {
                Image(systemName: "plus")
                    .font(.system(size: DesignTokens.fabIconSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: DesignTokens.fabSize, height: DesignTokens.fabSize)
                    .background(colors.primaryAccent)
                    .clipShape(Circle())
                    .shadow(color: colors.primaryAccent.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.trailing, DesignTokens.horizontalPadding)
            .padding(.bottom, 70)
        }
        .onAppear {
            viewModel.initializeExpandedCategories(from: items)
        }
    }
}
