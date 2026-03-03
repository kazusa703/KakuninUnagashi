import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.appColors) private var colors
    let notificationManager: NotificationManager
    @State private var notificationEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(String(localized: "通知", comment: "Notifications"))
                    .font(DesignTokens.navTitleFont)
                    .foregroundStyle(colors.primaryText)
                Spacer()
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 8)

            CustomCardView {
                VStack(spacing: 0) {
                    SettingsRowView(
                        icon: "bell.fill",
                        title: String(localized: "通知を許可", comment: "Allow notifications"),
                        trailingContent: {
                            AnyView(
                                Toggle("", isOn: $notificationEnabled)
                                    .tint(colors.primaryAccent)
                                    .labelsHidden()
                            )
                        }
                    )
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 12)

            Spacer()
        }
        .background(colors.background)
        .task {
            await notificationManager.checkAuthorizationStatus()
            notificationEnabled = notificationManager.isAuthorized
        }
        .onChange(of: notificationEnabled) { _, newValue in
            if newValue {
                Task { await notificationManager.requestAuthorization() }
            }
        }
    }
}

struct SettingsRowView<Trailing: View>: View {
    @Environment(\.appColors) private var colors
    let icon: String
    let title: String
    let trailingContent: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(colors.primaryAccent)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(colors.primaryText)
            Spacer()
            trailingContent()
        }
        .padding(.horizontal, DesignTokens.horizontalPadding)
        .padding(.vertical, 12)
    }
}
