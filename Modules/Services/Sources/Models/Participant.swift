import Foundation
import ProtobufMessages
import AnytypeCore

public typealias ParticipantPermissions = Anytype_Model_ParticipantPermissions
public typealias ParticipantStatus = Anytype_Model_ParticipantStatus

public struct Participant: Identifiable, Equatable {
    
    public let id: String
    public let name: String
    public let icon: ObjectIcon?
    public let status: ParticipantStatus
    public let permission: ParticipantPermissions
    public let identity: String
    public let spaceId: String
    
    public init(details: ObjectDetails) throws {
        self.id = details.id
        self.name = details.objectName
        self.icon = details.objectIcon
        guard let status = details.participantStatusValue else {
            anytypeAssertionFailure("Participant status error", info: ["value": details.participantStatus?.description ?? "nil"])
            throw CommonError.undefined
        }
        self.status = status
        guard let permission = details.participantPermissionsValue else {
            anytypeAssertionFailure("Participant permission error", info: ["value": details.participantPermissions?.description ?? "nil"])
            throw CommonError.undefined
        }
        self.permission = permission
        self.identity = details.identity
        self.spaceId = details.spaceId
    }
}

public extension Participant {
    static var subscriptionKeys: [BundledRelationKey] {
        .builder {
            BundledRelationKey.objectListKeys
            BundledRelationKey.participantStatus
            BundledRelationKey.participantPermissions
            BundledRelationKey.identity
        }
    }
}
