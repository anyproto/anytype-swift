import Foundation
import ProtobufMessages
import AnytypeCore

public typealias ParticipantPermissions = Anytype_Model_ParticipantPermissions
public typealias ParticipantStatus = Anytype_Model_ParticipantStatus

public struct Participant: Identifiable, Equatable, Sendable, Hashable {
    
    public let id: String
    public let localName: String
    public let globalName: String
    public let icon: ObjectIcon?
    public let status: ParticipantStatus
    public let permission: ParticipantPermissions
    public let identity: String
    public let identityProfileLink: String
    public let spaceId: String
    public let type: String
    
    public init(
        id: String,
        localName: String,
        globalName: String,
        icon: ObjectIcon?,
        status: ParticipantStatus,
        permission: ParticipantPermissions,
        identity: String,
        identityProfileLink: String,
        spaceId: String,
        type: String
    ) {
        self.id = id
        self.localName = localName
        self.globalName = globalName
        self.icon = icon
        self.status = status
        self.permission = permission
        self.identity = identity
        self.identityProfileLink = identityProfileLink
        self.spaceId = spaceId
        self.type = type
    }
}

extension Participant: DetailsModel {
    
    public init(details: ObjectDetails) throws {
        self.id = details.id
        self.localName = details.objectName
        self.globalName = details.globalName
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
    
    
    public static var subscriptionKeys: [BundledPropertyKey] {
        .builder {
            BundledPropertyKey.objectListKeys
            BundledPropertyKey.participantStatus
            BundledPropertyKey.participantPermissions
            BundledPropertyKey.identity
            BundledPropertyKey.identityProfileLink
            BundledPropertyKey.globalName
        }
    }
}
