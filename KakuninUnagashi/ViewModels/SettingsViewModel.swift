import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    var showDeleteAllConfirmation = false
    var showExportSheet = false
    var exportURL: URL?

    func exportData(items: [CheckItem]) {
        do {
            let data = try ExportManager.exportToJSON(items: items)
            let url = ExportManager.exportFileURL()
            try data.write(to: url)
            exportURL = url
            showExportSheet = true
        } catch {
            // Export failed
        }
    }

    func deleteAllData(context: ModelContext) {
        do {
            try context.delete(model: Confirmation.self)
            try context.delete(model: CheckItem.self)
            try context.delete(model: CheckCategory.self)
            try context.save()

            // Re-create default categories
            for category in CheckCategory.defaultCategories() {
                context.insert(category)
            }
            try context.save()
        } catch {
            // Deletion failed
        }
    }
}
