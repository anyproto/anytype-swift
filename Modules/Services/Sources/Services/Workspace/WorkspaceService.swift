import Foundation
import ProtobufMessages
import AnytypeCore

public protocol WorkspaceServiceProtocol: Sendable {
    func installObjects(spaceId: String, objectIds: [String]) async throws -> [String]
    func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails
    
    func createSpace(name: String, iconOption: Int, accessType: SpaceAccessType, useCase: UseCase, withChat: Bool, uxType: SpaceUxType) async throws -> WorkspaceCreateResponse
    func workspaceOpen(spaceId: String, withChat: Bool) async throws -> AccountInfo
    func workspaceSetDetails(spaceId: String, details: [WorkspaceSetDetails]) async throws
    func workspaceExport(spaceId: String, path: String) async throws -> String
    func deleteSpace(spaceId: String) async throws
    func inviteView(cid: String, key: String) async throws -> SpaceInviteView
    func join(spaceId: String, cid: String, key: String, networkId: String) async throws
    func joinCancel(spaceId: String) async throws
    func generateInvite(spaceId: String) async throws -> SpaceInvite
    func revokeInvite(spaceId: String) async throws
    func stopSharing(spaceId: String) async throws
    func makeSharable(spaceId: String) async throws
    func getCurrentInvite(spaceId: String) async throws -> SpaceInvite
    func getGuestInvite(spaceId: String) async throws -> SpaceInvite
    func requestApprove(spaceId: String, identity: String, permissions: ParticipantPermissions) async throws
    func requestDecline(spaceId: String, identity: String) async throws
    func participantPermissionsChange(spaceId: String, identity: String, permissions: ParticipantPermissions) async throws
    func participantRemove(spaceId: String, identity: String) async throws
    func leaveApprove(spaceId: String, identity: String) async throws
    func pushNotificationSetSpaceMode(spaceId: String, mode: SpacePushNotificationsMode) async throws
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
    
    public func createSpace(name: String, iconOption: Int, accessType: SpaceAccessType, useCase: UseCase, withChat: Bool, uxType: SpaceUxType) async throws -> WorkspaceCreateResponse {
        let result = try await ClientCommands.workspaceCreate(.with {
            $0.details.fields[BundledPropertyKey.name.rawValue] = name.protobufValue
            $0.details.fields[BundledPropertyKey.iconOption.rawValue] = iconOption.protobufValue
            $0.details.fields[BundledPropertyKey.spaceAccessType.rawValue] = accessType.rawValue.protobufValue
            $0.details.fields[BundledPropertyKey.spaceUxType.rawValue] = uxType.rawValue.protobufValue
            $0.useCase = useCase
            $0.withChat = withChat
        }).invoke()
        return result
    }
    
    public func workspaceOpen(spaceId: String, withChat: Bool) async throws -> AccountInfo {
        let result = try await ClientCommands.workspaceOpen(.with {
            $0.spaceID = spaceId
            $0.withChat = withChat
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
        do {
            let result = try await ClientCommands.spaceInviteView(.with {
                $0.inviteCid = cid
                $0.inviteFileKey = key
            }).invoke(ignoreLogErrors: .inviteNotFound)
            return result.asModel()
        } catch let error as Anytype_Rpc.Space.InviteView.Response.Error where error.code == .spaceIsDeleted {
            throw SpaceInviteViewError.spaceIsDeleted
        } catch let error as Anytype_Rpc.Space.InviteView.Response.Error where error.code == .inviteNotFound {
            throw SpaceInviteViewError.inviteNotFound
        } catch {
            throw error
        }
    }
    
    public func join(spaceId: String, cid: String, key: String, networkId: String) async throws {
        do {
            try await ClientCommands.spaceJoin(.with {
                $0.spaceID = spaceId
                $0.inviteCid = cid
                $0.inviteFileKey = key
                $0.networkID = networkId
            }).invoke()
        } catch let error as Anytype_Rpc.Space.Join.Response.Error where error.code == .limitReached {
            throw SpaceJoinError.limitReached
        } catch {
            throw error
        }
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
    
    public func getGuestInvite(spaceId: String) async throws -> SpaceInvite {
        let result = try await ClientCommands.spaceInviteGetGuest(.with {
            $0.spaceID = spaceId
        }).invoke()
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
    
    public func pushNotificationSetSpaceMode(spaceId: String, mode: SpacePushNotificationsMode) async throws {
        try await ClientCommands.pushNotificationSetSpaceMode(.with {
            $0.spaceID = spaceId
            $0.mode = mode
        }).invoke()
    }
}
