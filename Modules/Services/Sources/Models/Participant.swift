import Foundation
import ProtobufMessages
import AnytypeCore

public typealias ParticipantPermissions = Anytype_Model_ParticipantPermissions
public typealias ParticipantStatus = Anytype_Model_ParticipantStatus

public struct Participant: Identifiable, Equatable, Sendable, Hashable, DetailsModel {
    
    public let id: String
    public let localName: String
    public let globalName: String
    public let description: String
    public let icon: ObjectIcon
    public let status: ParticipantStatus
    public let permission: ParticipantPermissions
    public let identity: String
    public let identityProfileLink: String
    public let spaceId: String
    public let type: String
    
    public init(details: ObjectDetails) throws {
        self.id = details.id
        self.localName = details.objectName
        self.globalName = details.globalName
        self.description = details.description
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
        self.identityProfileLink = details.identityProfileLink
        self.spaceId = details.spaceId
        self.type = details.type
    }
    
    public static var subscriptionKeys: [BundledRelationKey] {
        .builder {
            BundledRelationKey.objectListKeys
            BundledRelationKey.participantStatus
            BundledRelationKey.participantPermissions
            BundledRelationKey.identity
            BundledRelationKey.identityProfileLink
            BundledRelationKey.globalName
        }
    }
}
