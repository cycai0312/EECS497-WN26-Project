import Foundation
import SwiftData

enum UserRole: String, Codable, CaseIterable {
    case patient
    case caregiver
}

@Model
final class AppUser {
    @Attribute(.unique) var id: UUID
    var name: String
    var roleRawValue: String

    var role: UserRole {
        get { UserRole(rawValue: roleRawValue) ?? .patient }
        set { roleRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, role: UserRole) {
        self.id = id
        self.name = name
        self.roleRawValue = role.rawValue
    }
}
