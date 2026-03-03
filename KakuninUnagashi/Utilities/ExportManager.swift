import Foundation
import SwiftData

enum ExportManager {
    struct ExportData: Codable {
        let exportDate: Date
        let items: [ExportItem]
    }

    struct ExportItem: Codable {
        let name: String
        let categoryName: String
        let categoryEmoji: String
        let scheduleType: String
        let intervalValue: Int
        let intervalUnit: String
        let nextDueDate: Date
        let memo: String?
        let createdAt: Date
        let confirmations: [ExportConfirmation]
    }

    struct ExportConfirmation: Codable {
        let confirmedAt: Date
        let memo: String?
        let hasPhoto: Bool
    }

    static func exportToJSON(items: [CheckItem]) throws -> Data {
        let exportItems = items.map { item in
            ExportItem(
                name: item.name,
                categoryName: item.category?.name ?? "",
                categoryEmoji: item.category?.emoji ?? "",
                scheduleType: item.scheduleTypeRaw,
                intervalValue: item.intervalValue,
                intervalUnit: item.intervalUnitRaw,
                nextDueDate: item.nextDueDate,
                memo: item.memo,
                createdAt: item.createdAt,
                confirmations: item.confirmations.map { conf in
                    ExportConfirmation(
                        confirmedAt: conf.confirmedAt,
                        memo: conf.memo,
                        hasPhoto: conf.photoData != nil
                    )
                }
            )
        }

        let exportData = ExportData(exportDate: Date(), items: exportItems)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(exportData)
    }

    static func exportFileURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "kakunin_export_\(formatter.string(from: Date())).json"
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
}
