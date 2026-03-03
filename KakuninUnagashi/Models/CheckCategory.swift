import Foundation
import SwiftData

@Model
final class CheckCategory {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var sortOrder: Int
    var isDefault: Bool

    @Relationship(deleteRule: .nullify, inverse: \CheckItem.category)
    var items: [CheckItem] = []

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        colorHex: String,
        sortOrder: Int,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    /// Default categories created on first launch
    static func defaultCategories() -> [CheckCategory] {
        [
            CheckCategory(name: "家", emoji: "🏠", colorHex: "#4A90D9", sortOrder: 0, isDefault: true),
            CheckCategory(name: "車", emoji: "🚗", colorHex: "#E67E22", sortOrder: 1, isDefault: true),
            CheckCategory(name: "健康", emoji: "💊", colorHex: "#27AE60", sortOrder: 2, isDefault: true),
            CheckCategory(name: "安全", emoji: "🛡️", colorHex: "#E74C3C", sortOrder: 3, isDefault: true),
            CheckCategory(name: "お金", emoji: "💰", colorHex: "#F39C12", sortOrder: 4, isDefault: true),
            CheckCategory(name: "その他", emoji: "📋", colorHex: "#8E8E93", sortOrder: 5, isDefault: true),
        ]
    }
}
