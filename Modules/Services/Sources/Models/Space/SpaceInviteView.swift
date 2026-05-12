import Foundation
import ProtobufMessages

public struct SpaceInviteView: Sendable {
    public let spaceId: String
    public let spaceName: String
    public let spaceIconCid: String
    public let creatorName: String
    public let inviteType: InviteType
    public let spaceUxType: SpaceUxType
}

extension Anytype_Rpc.Space.InviteView.Response {
    func asModel() -> SpaceInviteView {
        return SpaceInviteView(
            spaceId: spaceID,
            spaceName: spaceName,
            spaceIconCid: spaceIconCid,
            creatorName: creatorName,
            inviteType: inviteType,
            spaceUxType: SpaceUxType(rawValue: Int(spaceUxType)) ?? .data
        )
    }
}

public extension InviteType {
    var withoutApprove: Bool {
        self == .withoutApprove
    }
}
