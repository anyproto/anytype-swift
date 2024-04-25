import Foundation
import ProtobufMessages
import AnytypeCore

public protocol WorkspaceServiceProtocol {
    func installObjects(spaceId: String, objectIds: [String]) async throws -> [String]
    func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails
    
    func createSpace(name: String, gradient: GradientId, accessType: SpaceAccessType, useCase: UseCase) async throws -> String
    func workspaceOpen(spaceId: String) async throws -> AccountInfo
    func workspaceSetDetails(spaceId: String, details: [WorkspaceSetDetails]) async throws
    func workspaceExport(spaceId: String, path: String) async throws -> String
    func deleteSpace(spaceId: String) async throws
    func inviteView(cid: String, key: String) async throws -> SpaceInviteView
    func join(spaceId: String, cid: String, key: String) async throws
    func joinCancel(spaceId: String) async throws
    func generateInvite(spaceId: String) async throws -> SpaceInvite
    func revokeInvite(spaceId: String) async throws
    func stopSharing(spaceId: String) async throws
    func makeSharable(spaceId: String) async throws
    func getCurrentInvite(spaceId: String) async throws -> SpaceInvite
    func requestApprove(spaceId: String, identity: String, permissions: ParticipantPermissions) async throws
    func requestDecline(spaceId: String, identity: String) async throws
    func participantPermissionsChange(spaceId: String, identity: String, permissions: ParticipantPermissions) async throws
    func participantRemove(spaceId: String, identity: String) async throws
    func leaveApprove(spaceId: String, identity: String) async throws
}

final class WorkspaceService: WorkspaceServiceProtocol {
    
    // MARK: - WorkspaceServiceProtocol
    
    public func installObjects(spaceId: String, objectIds: [String]) async throws -> [String] {
        try await ClientCommands.workspaceObjectListAdd(.with {
            $0.objectIds = objectIds
            $0.spaceID = spaceId
		}).invoke()
			.objectIds
    }
    
    public func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails {
        let result = try await ClientCommands.workspaceObjectAdd(.with {
            $0.objectID = objectId
            $0.spaceID = spaceId
        }).invoke()
        
		return try ObjectDetails(protobufStruct: result.details)
    }
    
    public func createSpace(name: String, gradient: GradientId, accessType: SpaceAccessType, useCase: UseCase) async throws -> String {
        let result = try await ClientCommands.workspaceCreate(.with {
            $0.details.fields[BundledRelationKey.name.rawValue] = name.protobufValue
            $0.details.fields[BundledRelationKey.iconOption.rawValue] = gradient.rawValue.protobufValue
            $0.details.fields[BundledRelationKey.spaceAccessType.rawValue] = accessType.rawValue.protobufValue
            $0.useCase = useCase.toMiddleware()
        }).invoke()
        return result.spaceID
    }
    
    public func workspaceOpen(spaceId: String) async throws -> AccountInfo {
        let result = try await ClientCommands.workspaceOpen(.with {
            $0.spaceID = spaceId
        }).invoke()
        
        return result.info.asModel
    }
    
    public func workspaceSetDetails(spaceId: String, details: [WorkspaceSetDetails]) async throws {
        try await ClientCommands.workspaceSetInfo(.with {
            $0.spaceID = spaceId
            for detail in details {
                $0.details.fields[detail.key] = detail.value
            }
        }).invoke()
    }
    
    func workspaceExport(spaceId: String, path: String) async throws -> String {
        let result = try await ClientCommands.objectListExport(.with {
            $0.spaceID = spaceId
            $0.path = path
            $0.zip = true
            $0.includeFiles = true
            $0.includeArchived = true
            $0.includeNested = true
            $0.isJson = false
        }).invoke()
        return result.path
    }
    
    public func deleteSpace(spaceId: String) async throws {
        try await ClientCommands.spaceDelete(.with {
            $0.spaceID = spaceId
        }).invoke()
    }
    
    public func inviteView(cid: String, key: String) async throws -> SpaceInviteView {
        let result = try await ClientCommands.spaceInviteView(.with {
            $0.inviteCid = cid
            $0.inviteFileKey = key
        }).invoke(ignoreLogErrors: .inviteNotFound)
        return result.asModel()
    }
    
    public func join(spaceId: String, cid: String, key: String) async throws {
        try await ClientCommands.spaceJoin(.with {
            $0.spaceID = spaceId
            $0.inviteCid = cid
            $0.inviteFileKey = key
        }).invoke()
    }
    
    public func joinCancel(spaceId: String) async throws {
        try await ClientCommands.spaceJoinCancel(.with {
            $0.spaceID = spaceId
        }).invoke()
    }
    
    public func generateInvite(spaceId: String) async throws -> SpaceInvite {
        let result = try await ClientCommands.spaceInviteGenerate(.with {
            $0.spaceID = spaceId
        }).invoke()
        return result.asModel()
    }
    
    public func revokeInvite(spaceId: String) async throws {
        try await ClientCommands.spaceInviteRevoke(.with {
            $0.spaceID = spaceId
        }).invoke()
    }
    
    public func stopSharing(spaceId: String) async throws {
        try await ClientCommands.spaceStopSharing(.with {
            $0.spaceID = spaceId
        }).invoke()
    }
    
    public func makeSharable(spaceId: String) async throws {
        try await ClientCommands.spaceMakeShareable(.with {
            $0.spaceID = spaceId
        }).invoke()
    }
    
    public func getCurrentInvite(spaceId: String) async throws -> SpaceInvite {
        let result = try await ClientCommands.spaceInviteGetCurrent(.with {
            $0.spaceID = spaceId
        }).invoke(ignoreLogErrors: .noActiveInvite)
        return result.asModel()
    }
    
    public func requestApprove(spaceId: String, identity: String, permissions: ParticipantPermissions) async throws {
        try await ClientCommands.spaceRequestApprove(.with {
            $0.spaceID = spaceId
            $0.identity = identity
            $0.permissions = permissions
        }).invoke()
    }
    
    public func requestDecline(spaceId: String, identity: String) async throws {
        try await ClientCommands.spaceRequestDecline(.with {
            $0.spaceID = spaceId
            $0.identity = identity
        }).invoke()
    }
    
    public func participantPermissionsChange(spaceId: String, identity: String, permissions: ParticipantPermissions) async throws {
        try await ClientCommands.spaceParticipantPermissionsChange(.with {
            $0.spaceID = spaceId
            $0.changes = [
                Anytype_Model_ParticipantPermissionChange.with {
                    $0.identity = identity
                    $0.perms = permissions
                }
            ]
        }).invoke()
    }
    
    public func participantRemove(spaceId: String, identity: String) async throws {
        try await ClientCommands.spaceParticipantRemove(.with {
            $0.spaceID = spaceId
            $0.identities = [identity]
        }).invoke()
    }
    
    public func leaveApprove(spaceId: String, identity: String) async throws {
        try await ClientCommands.spaceLeaveApprove(.with {
            $0.spaceID = spaceId
            $0.identities = [identity]
        }).invoke()
    }
}
