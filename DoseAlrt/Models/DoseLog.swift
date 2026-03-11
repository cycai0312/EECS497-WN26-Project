import Foundation
import SwiftData

enum DoseStatus: String, Codable, CaseIterable {
    case taken
    case skipped
    case maybeLater

    var title: String {
        switch self {
        case .taken: return "Taken"
        case .skipped: return "Skipped"
        case .maybeLater: return "Maybe Later"
        }
    }
}

@Model
final class DoseLog {
    @Attribute(.unique) var id: UUID
    var medicationID: UUID
    var medicationNameSnapshot: String
    var timestamp: Date
    var statusRawValue: String

    var status: DoseStatus {
        get { DoseStatus(rawValue: statusRawValue) ?? .taken }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        medicationID: UUID,
        medicationNameSnapshot: String,
        timestamp: Date = Date(),
        status: DoseStatus
    ) {
        self.id = id
        self.medicationID = medicationID
        self.medicationNameSnapshot = medicationNameSnapshot
        self.timestamp = timestamp
        self.statusRawValue = status.rawValue
    }
}
