import Foundation
import ProtobufMessages
import AnytypeCore

public struct SpaceInvite: Sendable {
    public let cid: String
    public let fileKey: String
    public let inviteType: InviteType?
    public let permissions: InvitePermissions?
    public let heldByOwner: Bool

    // A member's InviteGetCurrent succeeds with an empty cid when the invite is held by the owner
    public var hasLink: Bool { cid.isNotEmpty }
}

extension Anytype_Rpc.Space.InviteGenerate.Response {
    func asModel(shareWithinSpace: Bool) -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey, inviteType: inviteType, permissions: permissions, heldByOwner: !shareWithinSpace)
    }
}

extension Anytype_Rpc.Space.InviteGetCurrent.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey, inviteType: inviteType, permissions: permissions, heldByOwner: heldByOwner)
    }
}

extension Anytype_Rpc.Space.InviteGetGuest.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey, inviteType: nil, permissions: nil, heldByOwner: false)
    }
}
