import Foundation
import Services

struct PendingShareState: Codable, Equatable {
    let spaceId: String
    let identities: [PendingIdentity]
    var needsMakeShareable: Bool
    var needsGenerateInvite: Bool
}

struct PendingIdentity: Codable, Equatable {
    let identity: String
    let name: String
    let globalName: String
    let icon: ObjectIcon?
}
