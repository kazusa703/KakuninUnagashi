import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct KakuninEntry: TimelineEntry {
    let date: Date
    let uncheckedCount: Int
    let items: [WidgetItem]
}

struct WidgetItem: Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let dueStatus: String
    let isOverdue: Bool
    let isDueToday: Bool
}

// MARK: - Timeline Provider

struct KakuninProvider: TimelineProvider {
    /// App Group ID - configure in Xcode target capabilities
    static let appGroupID = "group.com.imai.KakuninUnagashi"

    func placeholder(in _: Context) -> KakuninEntry {
        KakuninEntry(
            date: Date(),
            uncheckedCount: 3,
            items: [
                WidgetItem(id: UUID(), name: "エアコンフィルター", emoji: "🏠", dueStatus: "2日超過", isOverdue: true, isDueToday: false),
                WidgetItem(id: UUID(), name: "煙感知器テスト", emoji: "🏠", dueStatus: "今日", isOverdue: false, isDueToday: true),
                WidgetItem(id: UUID(), name: "タイヤ空気圧", emoji: "🚗", dueStatus: "あと3日", isOverdue: false, isDueToday: false),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (KakuninEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<KakuninEntry>) -> Void) {
        // Read shared data from UserDefaults
        let entry = loadWidgetData()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadWidgetData() -> KakuninEntry {
        guard let defaults = UserDefaults(suiteName: Self.appGroupID),
              let data = defaults.data(forKey: "widgetItems"),
              let widgetData = try? JSONDecoder().decode(SharedWidgetData.self, from: data)
        else {
            return KakuninEntry(date: Date(), uncheckedCount: 0, items: [])
        }

        let items = widgetData.items.map { item in
            WidgetItem(
                id: item.id,
                name: item.name,
                emoji: item.emoji,
                dueStatus: item.dueStatus,
                isOverdue: item.isOverdue,
                isDueToday: item.isDueToday
            )
        }

        return KakuninEntry(date: Date(), uncheckedCount: widgetData.uncheckedCount, items: items)
    }
}

// MARK: - Shared Data Model

struct SharedWidgetData: Codable {
    let uncheckedCount: Int
    let items: [SharedWidgetItem]
}

struct SharedWidgetItem: Codable {
    let id: UUID
    let name: String
    let emoji: String
    let dueStatus: String
    let isOverdue: Bool
    let isDueToday: Bool
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: KakuninEntry

    var body: some View {
        VStack(spacing: 4) {
            Text("確認促し")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text("\(entry.uncheckedCount)")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(entry.uncheckedCount > 0 ? Color(hex: "#2D8CFF") : .secondary)

            Text("未確認")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            if let firstItem = entry.items.first {
                HStack(spacing: 4) {
                    Text("次:")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(firstItem.name)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: KakuninEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("確認促し")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("今日 \(entry.uncheckedCount)件")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "#2D8CFF"))
            }

            if entry.items.isEmpty {
                Spacer()
                Text("確認項目はありません")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(entry.items.prefix(3)) { item in
                    HStack(spacing: 8) {
                        Text(item.emoji)
                            .font(.system(size: 14))
                        Text(item.name)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                        Spacer()
                        Text(item.dueStatus)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(statusColor(for: item))
                    }
                }
            }
        }
        .padding(14)
    }

    private func statusColor(for item: WidgetItem) -> Color {
        if item.isOverdue {
            return Color(hex: "#FF3B30")
        } else if item.isDueToday {
            return Color(hex: "#2D8CFF")
        } else {
            return .secondary
        }
    }
}

// MARK: - Color Extension for Widget

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
        .description("未確認の項目を確認できます")
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

#Preview(as: .systemSmall) {
    KakuninUnagashiwidget()
} timeline: {
    KakuninEntry(date: .now, uncheckedCount: 3, items: [
        WidgetItem(id: UUID(), name: "エアコンフィルター", emoji: "🏠", dueStatus: "2日超過", isOverdue: true, isDueToday: false),
    ])
}

#Preview(as: .systemMedium) {
    KakuninUnagashiwidget()
} timeline: {
    KakuninEntry(date: .now, uncheckedCount: 3, items: [
        WidgetItem(id: UUID(), name: "エアコンフィルター", emoji: "🏠", dueStatus: "2日超過", isOverdue: true, isDueToday: false),
        WidgetItem(id: UUID(), name: "煙感知器テスト", emoji: "🏠", dueStatus: "今日", isOverdue: false, isDueToday: true),
        WidgetItem(id: UUID(), name: "タイヤ空気圧", emoji: "🚗", dueStatus: "あと3日", isOverdue: false, isDueToday: false),
    ])
}
