import SwiftUI
import WidgetKit

// MARK: - Theme Constants

private enum WidgetTheme {
    static let accentBlue = Color(hex: "#2D8CFF")
    static let overdueRed = Color(hex: "#FF3B30")
    static let confirmedGreen = Color(hex: "#34C759")
    static let margin: CGFloat = 16
    static let rowSpacing: CGFloat = 8
    static let ringLineWidth: CGFloat = 6
    static let ringSize: CGFloat = 56
}

// MARK: - Timeline Entry

struct KakuninEntry: TimelineEntry {
    let date: Date
    let totalDueCount: Int
    let completedTodayCount: Int
    let items: [WidgetItem]

    var pendingCount: Int {
        totalDueCount - completedTodayCount
    }

    var isAllDone: Bool {
        totalDueCount > 0 && pendingCount <= 0
    }

    var hasNoItems: Bool {
        totalDueCount == 0 && items.isEmpty
    }

    var progress: Double {
        guard totalDueCount > 0 else { return 1.0 }
        return Double(completedTodayCount) / Double(totalDueCount)
    }
}

struct WidgetItem: Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let categoryColor: String
    let dueStatus: String
    let dueTime: String?
    let isOverdue: Bool
    let isDueToday: Bool
    let daysUntilDue: Int
}

// MARK: - Timeline Provider

struct KakuninProvider: TimelineProvider {
    static let appGroupID = "group.com.imai.KakuninUnagashi"

    func placeholder(in _: Context) -> KakuninEntry {
        KakuninEntry(
            date: Date(),
            totalDueCount: 5,
            completedTodayCount: 2,
            items: [
                WidgetItem(id: UUID(), name: "エアコンフィルター掃除", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "2日超過", dueTime: nil, isOverdue: true, isDueToday: false, daysUntilDue: -2),
                WidgetItem(id: UUID(), name: "煙感知器テスト", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "今日", dueTime: "9:00", isOverdue: false, isDueToday: true, daysUntilDue: 0),
                WidgetItem(id: UUID(), name: "タイヤ空気圧チェック", emoji: "🚗", categoryColor: "#E67E22", dueStatus: "あと3日", dueTime: nil, isOverdue: false, isDueToday: false, daysUntilDue: 3),
                WidgetItem(id: UUID(), name: "浄水フィルター交換", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "あと5日", dueTime: nil, isOverdue: false, isDueToday: false, daysUntilDue: 5),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (KakuninEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<KakuninEntry>) -> Void) {
        let entry = loadWidgetData()

        // Next update: start of next hour or midnight (whichever is sooner)
        let calendar = Calendar.current
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: Date())!
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let nextUpdate = min(nextHour, tomorrow)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadWidgetData() -> KakuninEntry {
        guard let defaults = UserDefaults(suiteName: Self.appGroupID),
              let data = defaults.data(forKey: "widgetItems"),
              let widgetData = try? JSONDecoder().decode(SharedWidgetData.self, from: data)
        else {
            return KakuninEntry(date: Date(), totalDueCount: 0, completedTodayCount: 0, items: [])
        }

        let items = widgetData.items.map { item in
            WidgetItem(
                id: item.id,
                name: item.name,
                emoji: item.emoji,
                categoryColor: item.categoryColor,
                dueStatus: item.dueStatus,
                dueTime: item.dueTime,
                isOverdue: item.isOverdue,
                isDueToday: item.isDueToday,
                daysUntilDue: item.daysUntilDue
            )
        }

        return KakuninEntry(
            date: Date(),
            totalDueCount: widgetData.totalDueCount,
            completedTodayCount: widgetData.completedTodayCount,
            items: items
        )
    }
}

// MARK: - Shared Data Models

struct SharedWidgetData: Codable {
    let totalDueCount: Int
    let completedTodayCount: Int
    let items: [SharedWidgetItem]
}

struct SharedWidgetItem: Codable {
    let id: UUID
    let name: String
    let emoji: String
    let categoryColor: String
    let dueStatus: String
    let dueTime: String?
    let isOverdue: Bool
    let isDueToday: Bool
    let daysUntilDue: Int
}

// MARK: - Small Widget View (Progress Ring + Next Item Focus)

struct SmallWidgetView: View {
    let entry: KakuninEntry

    var body: some View {
        if entry.hasNoItems {
            smallEmptyState
        } else if entry.isAllDone {
            smallAllDoneState
        } else {
            smallActiveState
        }
    }

    // Active: show progress ring + next item
    private var smallActiveState: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("今日の確認")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Spacer()

            // Progress ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(.quaternary, lineWidth: WidgetTheme.ringLineWidth)

                // Progress arc
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(
                        WidgetTheme.accentBlue,
                        style: StrokeStyle(lineWidth: WidgetTheme.ringLineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Center text
                VStack(spacing: 0) {
                    Text("\(entry.completedTodayCount)/\(entry.totalDueCount)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetTheme.accentBlue)
                    Text("完了")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: WidgetTheme.ringSize, height: WidgetTheme.ringSize)

            Spacer()

            // Next item preview
            if let next = entry.items.first {
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(for: next))
                        .frame(width: 6, height: 6)
                    Text(next.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(WidgetTheme.margin)
    }

    /// All done
    private var smallAllDoneState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(WidgetTheme.confirmedGreen)
            Text("全て確認済み")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
            Text("お疲れさまでした")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(WidgetTheme.margin)
    }

    /// No items
    private var smallEmptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundStyle(.tertiary)
            Text("確認項目なし")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(WidgetTheme.margin)
    }

    private func statusColor(for item: WidgetItem) -> Color {
        if item.isOverdue { return WidgetTheme.overdueRed }
        if item.isDueToday { return WidgetTheme.accentBlue }
        return .secondary
    }
}

// MARK: - Medium Widget View (Checklist + Progress Header)

struct MediumWidgetView: View {
    let entry: KakuninEntry

    var body: some View {
        if entry.hasNoItems {
            mediumEmptyState
        } else if entry.isAllDone {
            mediumAllDoneState
        } else {
            mediumActiveState
        }
    }

    // Active: header + checklist rows
    private var mediumActiveState: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .center) {
                // Mini progress ring
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 3.5)
                    Circle()
                        .trim(from: 0, to: entry.progress)
                        .stroke(WidgetTheme.accentBlue, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 22, height: 22)

                Text("今日の確認")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(entry.completedTodayCount)/\(entry.totalDueCount) 完了")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WidgetTheme.accentBlue)
            }
            .padding(.bottom, 10)

            // Separator
            Rectangle()
                .fill(.quaternary)
                .frame(height: 0.5)
                .padding(.bottom, 6)

            // Item rows (max 4)
            let displayItems = Array(entry.items.prefix(4))
            let remaining = max(0, entry.items.count - 4)

            ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Spacer().frame(height: WidgetTheme.rowSpacing)
                }
                Link(destination: URL(string: "kakunin://item/\(item.id.uuidString)")!) {
                    itemRow(item)
                }
            }

            if remaining > 0 {
                Spacer().frame(height: 6)
                Text("他 \(remaining)件")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(WidgetTheme.margin)
    }

    private func itemRow(_ item: WidgetItem) -> some View {
        HStack(spacing: 10) {
            // Status indicator circle
            ZStack {
                Circle()
                    .stroke(statusColor(for: item).opacity(0.3), lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                if item.isOverdue {
                    Text("!")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(WidgetTheme.overdueRed)
                }
            }

            // Category emoji
            Text(item.emoji)
                .font(.system(size: 13))

            // Item name
            Text(item.name)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()

            // Due status badge
            Text(item.dueStatus)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(statusColor(for: item))
        }
    }

    /// All done
    private var mediumAllDoneState: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(WidgetTheme.confirmedGreen.opacity(0.2), lineWidth: 3.5)
                Circle()
                    .trim(from: 0, to: 1.0)
                    .stroke(WidgetTheme.confirmedGreen, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WidgetTheme.confirmedGreen)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("全て確認済み!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("今日の確認は全て完了しました")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(WidgetTheme.margin)
    }

    /// No items
    private var mediumEmptyState: some View {
        HStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundStyle(.tertiary)
            VStack(alignment: .leading, spacing: 2) {
                Text("確認項目がありません")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("アプリから項目を追加してください")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(WidgetTheme.margin)
    }

    private func statusColor(for item: WidgetItem) -> Color {
        if item.isOverdue { return WidgetTheme.overdueRed }
        if item.isDueToday { return WidgetTheme.accentBlue }
        if item.daysUntilDue <= 3 { return WidgetTheme.accentBlue.opacity(0.7) }
        return .secondary
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

// MARK: - Widget Definition

struct KakuninUnagashiwidget: Widget {
    let kind: String = "KakuninUnagashiwidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KakuninProvider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("確認促し")
        .description("今日の確認項目と進捗を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: KakuninEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    KakuninUnagashiwidget()
} timeline: {
    // Active state
    KakuninEntry(date: .now, totalDueCount: 5, completedTodayCount: 2, items: [
        WidgetItem(id: UUID(), name: "エアコンフィルター掃除", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "2日超過", dueTime: nil, isOverdue: true, isDueToday: false, daysUntilDue: -2),
    ])
    // All done
    KakuninEntry(date: .now, totalDueCount: 3, completedTodayCount: 3, items: [])
    // Empty
    KakuninEntry(date: .now, totalDueCount: 0, completedTodayCount: 0, items: [])
}

#Preview(as: .systemMedium) {
    KakuninUnagashiwidget()
} timeline: {
    // Active state
    KakuninEntry(date: .now, totalDueCount: 5, completedTodayCount: 2, items: [
        WidgetItem(id: UUID(), name: "エアコンフィルター掃除", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "2日超過", dueTime: nil, isOverdue: true, isDueToday: false, daysUntilDue: -2),
        WidgetItem(id: UUID(), name: "煙感知器テスト", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "今日", dueTime: "9:00", isOverdue: false, isDueToday: true, daysUntilDue: 0),
        WidgetItem(id: UUID(), name: "タイヤ空気圧チェック", emoji: "🚗", categoryColor: "#E67E22", dueStatus: "あと3日", dueTime: nil, isOverdue: false, isDueToday: false, daysUntilDue: 3),
        WidgetItem(id: UUID(), name: "浄水フィルター交換", emoji: "🏠", categoryColor: "#4A90D9", dueStatus: "あと5日", dueTime: nil, isOverdue: false, isDueToday: false, daysUntilDue: 5),
        WidgetItem(id: UUID(), name: "防災グッズ確認", emoji: "🛡️", categoryColor: "#E74C3C", dueStatus: "あと7日", dueTime: nil, isOverdue: false, isDueToday: false, daysUntilDue: 7),
    ])
    // All done
    KakuninEntry(date: .now, totalDueCount: 3, completedTodayCount: 3, items: [])
    // Empty
    KakuninEntry(date: .now, totalDueCount: 0, completedTodayCount: 0, items: [])
}
