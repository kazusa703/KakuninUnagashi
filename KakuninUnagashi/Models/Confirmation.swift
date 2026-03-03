import Foundation
import SwiftData

@Model
final class Confirmation {
    var id: UUID
    var confirmedAt: Date
    var memo: String?
    var photoData: Data?

    var checkItem: CheckItem?

    init(
        id: UUID = UUID(),
        confirmedAt: Date = Date(),
        memo: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = id
        self.confirmedAt = confirmedAt
        self.memo = memo
        self.photoData = photoData
    }
}
