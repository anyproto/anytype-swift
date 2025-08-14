import Foundation
import ProtobufMessages

public struct SpaceInvite: Sendable {
    public let cid: String
    public let fileKey: String
    public let inviteType: InviteType?
    public let permissions: InvitePermissions?
}

extension Anytype_Rpc.Space.InviteGenerate.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey, inviteType: inviteType, permissions: permissions)
    }
}

extension Anytype_Rpc.Space.InviteGetCurrent.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey, inviteType: inviteType, permissions: permissions)
    }
}

extension Anytype_Rpc.Space.InviteGetGuest.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey, inviteType: nil, permissions: nil)
    }
}
