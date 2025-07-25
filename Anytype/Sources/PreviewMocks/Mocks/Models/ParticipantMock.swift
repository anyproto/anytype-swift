import Services
import Foundation

extension Participant {
    
    static func mock() -> Self {
        let id = UUID().uuidString
        return Participant(
            id: id,
            localName: "Name \(id)",
            globalName: "Global Name \(id)",
            icon: .profile(.name(id)),
            status: .allCases.randomElement()!,
            permission: .allCases.randomElement()!,
            identity: "Identity \(id)",
            identityProfileLink: "Identity link \(id)",
            spaceId: id,
            type: ""
        )
    }
}
