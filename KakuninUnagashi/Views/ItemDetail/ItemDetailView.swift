import SwiftUI

struct ItemDetailView: View {
    @Environment(\.appColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: CheckItem
    @Bindable var viewModel: ItemDetailViewModel
    let notificationManager: NotificationManager

    @State private var addItemVM = AddItemViewModel()
    @State private var showEditSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Dynamic category header
                    headerView

                    VStack(spacing: 16) {
                        // Status card
                        StatusCardView(item: item)

                        // Settings info card
                        settingsInfoCard

                        // Confirmation history
                        ItemHistoryListView(confirmations: viewModel.recentConfirmations(item))
                    }
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }

            // Action bar
            VStack(spacing: 8) {
                SeparatorView()
                PrimaryButton(
                    title: String(localized: "今すぐ確認する", comment: "Confirm now button")
                ) {
                    Task {
                        await viewModel.confirmItem(item, context: modelContext, notificationManager: notificationManager)
                    }
                }
                .padding(.horizontal, DesignTokens.horizontalPadding)

                HStack(spacing: 24) {
                    Button {
                        addItemVM.loadItem(item)
                        showEditSheet = true
                    } label: {
                        Text(String(localized: "編集", comment: "Edit"))
                            .font(.system(size: 15))
                            .foregroundStyle(colors.primaryAccent)
                    }

                    Button {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        Text(String(localized: "削除", comment: "Delete"))
                            .font(.system(size: 15))
                            .foregroundStyle(colors.overdueRed)
                    }
                }
                .padding(.bottom, 8)
            }
            .background(colors.background)
        }
        .background(colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            String(localized: "項目を削除", comment: "Delete item alert"),
            isPresented: $viewModel.showDeleteConfirmation
        ) {
            Button(String(localized: "削除", comment: "Delete"), role: .destructive) {
                viewModel.deleteItem(item, context: modelContext)
                dismiss()
            }
            Button(String(localized: "キャンセル", comment: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "この項目と履歴が全て削除されます", comment: "Delete item message"))
        }
        .sheet(isPresented: $showEditSheet) {
            AddItemView(viewModel: addItemVM, notificationManager: notificationManager)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(hex: item.category?.colorHex ?? "#2D8CFF"),
                    Color(hex: item.category?.colorHex ?? "#2D8CFF").opacity(0.7),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.category?.emoji ?? "📋")
                    .font(.system(size: 40))
                Text(item.name)
                    .font(DesignTokens.detailTitleFont)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Settings Info Card

    private var settingsInfoCard: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 0) {
                infoRow(
                    label: String(localized: "スケジュールタイプ", comment: "Schedule type"),
                    value: item.scheduleType.localizedName
                )
                SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)

                if let notifTime = item.notificationTime {
                    infoRow(
                        label: String(localized: "通知時刻", comment: "Notification time"),
                        value: DateHelper.formatTime(notifTime)
                    )
                    SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)
                }

                if let category = item.category {
                    HStack {
                        Text(String(localized: "カテゴリ", comment: "Category"))
                            .font(DesignTokens.captionFont)
                            .foregroundStyle(colors.secondaryText)
                        Spacer()
                        CategoryBadgeView(category: category)
                    }
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.vertical, 12)
                    SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)
                }

                infoRow(
                    label: String(localized: "作成日", comment: "Created date"),
                    value: DateHelper.formatDate(item.createdAt)
                )

                if let memo = item.memo, !memo.isEmpty {
                    SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "メモ", comment: "Memo"))
                            .font(DesignTokens.captionFont)
                            .foregroundStyle(colors.secondaryText)
                        Text(memo)
                            .font(.system(size: 15))
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DesignTokens.captionFont)
                .foregroundStyle(colors.secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(colors.primaryText)
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
        .padding(.vertical, 12)
    }
}
