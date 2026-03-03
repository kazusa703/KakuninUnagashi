import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.appColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CheckItem]

    @Bindable var viewModel: SettingsViewModel
    let storeKitManager: StoreKitManager
    let notificationManager: NotificationManager

    @State private var showNotificationSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Text(String(localized: "設定", comment: "Settings tab"))
                    .font(DesignTokens.navTitleFont)
                    .foregroundStyle(colors.primaryText)
                Spacer()
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    // Purchase section
                    sectionHeader(String(localized: "課金", comment: "Purchase section"))
                    PurchaseCardView(storeKitManager: storeKitManager)

                    if !storeKitManager.isAdRemoved {
                        Button {
                            Task { await storeKitManager.restorePurchases() }
                        } label: {
                            Text(String(localized: "購入を復元", comment: "Restore purchases"))
                                .font(.system(size: 15))
                                .foregroundStyle(colors.primaryAccent)
                        }
                    }

                    // General section
                    sectionHeader(String(localized: "一般", comment: "General section"))
                    CustomCardView {
                        VStack(spacing: 0) {
                            NavigationLink {
                                NotificationSettingsView(notificationManager: notificationManager)
                                    .withAppTheme()
                            } label: {
                                settingsRow(icon: "bell.fill", title: String(localized: "通知設定", comment: "Notification settings"))
                            }
                            .buttonStyle(RowHighlightStyle())
                        }
                        .padding(.vertical, 4)
                    }

                    // Data section
                    sectionHeader(String(localized: "データ", comment: "Data section"))
                    CustomCardView {
                        VStack(spacing: 0) {
                            Button {
                                viewModel.exportData(items: items)
                            } label: {
                                settingsRow(icon: "square.and.arrow.up", title: String(localized: "データをエクスポート", comment: "Export data"))
                            }
                            .buttonStyle(RowHighlightStyle())

                            SeparatorView()
                                .padding(.horizontal, DesignTokens.horizontalPadding)

                            Button {
                                viewModel.showDeleteAllConfirmation = true
                            } label: {
                                settingsRow(
                                    icon: "trash",
                                    title: String(localized: "データの全削除", comment: "Delete all data"),
                                    isDestructive: true
                                )
                            }
                            .buttonStyle(RowHighlightStyle())
                        }
                        .padding(.vertical, 4)
                    }

                    // Info section
                    sectionHeader(String(localized: "情報", comment: "Info section"))
                    CustomCardView {
                        VStack(spacing: 0) {
                            settingsRow(icon: "doc.text", title: String(localized: "利用規約", comment: "Terms of service"))
                            SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)
                            settingsRow(icon: "hand.raised", title: String(localized: "プライバシーポリシー", comment: "Privacy policy"))
                            SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)
                            Link(destination: URL(string: "mailto:support@example.com")!) {
                                settingsRow(icon: "envelope", title: String(localized: "お問い合わせ", comment: "Contact us"))
                            }
                            SeparatorView().padding(.horizontal, DesignTokens.horizontalPadding)
                            settingsRow(
                                icon: "info.circle",
                                title: String(localized: "バージョン", comment: "Version"),
                                value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                            )
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, DesignTokens.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(colors.background)
        .alert(
            String(localized: "データの全削除", comment: "Delete all data alert title"),
            isPresented: $viewModel.showDeleteAllConfirmation
        ) {
            Button(String(localized: "削除", comment: "Delete button"), role: .destructive) {
                viewModel.deleteAllData(context: modelContext)
            }
            Button(String(localized: "キャンセル", comment: "Cancel button"), role: .cancel) {}
        } message: {
            Text(String(localized: "全てのデータが削除されます。この操作は取り消せません。", comment: "Delete confirmation message"))
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            if let url = viewModel.exportURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(colors.secondaryText)
                .textCase(.uppercase)
            Spacer()
        }
    }

    private func settingsRow(icon: String, title: String, value: String? = nil, isDestructive: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(isDestructive ? colors.overdueRed : colors.primaryAccent)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(isDestructive ? colors.overdueRed : colors.primaryText)
            Spacer()
            if let value {
                Text(value)
                    .font(.system(size: 15))
                    .foregroundStyle(colors.secondaryText)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(colors.secondaryText.opacity(0.5))
            }
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
        .padding(.vertical, 12)
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
