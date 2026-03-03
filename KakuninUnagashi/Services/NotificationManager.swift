import Foundation
import UserNotifications

@MainActor
@Observable
final class NotificationManager {
    private(set) var isAuthorized = false
    private let center = UNUserNotificationCenter.current()
    private let maxNotifications = 64

    func requestAuthorization() async {
        do {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleNotifications(for items: [CheckItem]) async {
        center.removeAllPendingNotificationRequests()

        // Sort by due date, schedule up to max limit
        let sortedItems = items.sorted { $0.nextDueDate < $1.nextDueDate }
        let itemsToSchedule = Array(sortedItems.prefix(maxNotifications / 2))

        for item in itemsToSchedule {
            await scheduleItemNotification(item)
            await schedulePreNotification(item)
        }
    }

    func updateBadge(count: Int) async {
        guard isAuthorized else { return }
        do {
            try await center.setBadgeCount(count)
        } catch {
            // Badge update failed silently
        }
    }

    // MARK: - Private

    private func scheduleItemNotification(_ item: CheckItem) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "確認の時間です", comment: "Notification title")
        content.body = String(localized: "\(item.name)の確認をしましょう", comment: "Notification body")
        content.sound = .default
        content.categoryIdentifier = "CONFIRM_ACTION"
        content.userInfo = ["itemID": item.id.uuidString]

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: item.nextDueDate
        )

        // Use item-specific time or default 9:00 AM
        if let notifTime = item.notificationTime {
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: notifTime)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
        } else {
            dateComponents.hour = 9
            dateComponents.minute = 0
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "item-\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // Notification scheduling failed
        }
    }

    private func schedulePreNotification(_ item: CheckItem) async {
        guard let preDate = Calendar.current.date(byAdding: .day, value: -1, to: item.nextDueDate),
              preDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "明日確認があります", comment: "Pre-notification title")
        content.body = String(localized: "\(item.name)の確認が明日です", comment: "Pre-notification body")
        content.sound = .default
        content.userInfo = ["itemID": item.id.uuidString]

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: preDate)
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "pre-\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // Pre-notification scheduling failed
        }
    }

    func setupNotificationActions() {
        let confirmAction = UNNotificationAction(
            identifier: "CONFIRM",
            title: String(localized: "確認済み", comment: "Confirm action"),
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: "CONFIRM_ACTION",
            actions: [confirmAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }
}
