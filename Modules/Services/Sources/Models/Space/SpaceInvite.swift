import Foundation
import ProtobufMessages

public struct SpaceInvite: Sendable {
    public let cid: String
    public let fileKey: String
}

extension Anytype_Rpc.Space.InviteGenerate.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey)
    }
}

extension Anytype_Rpc.Space.InviteGetCurrent.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey)
    }
}

extension Anytype_Rpc.Space.InviteGetGuest.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey)
    }
}
