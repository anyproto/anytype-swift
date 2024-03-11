import Foundation
import ProtobufMessages

public struct SpaceInviteView {
    public let spaceId: String
    public let spaceName: String
    public let spaceIconCid: String
    public let creatorName: String
}

extension Anytype_Rpc.Space.InviteView.Response {
    func asModel() -> SpaceInviteView {
        return SpaceInviteView(
            spaceId: spaceID,
            spaceName: spaceName,
            spaceIconCid: spaceIconCid,
            creatorName: creatorName
        )
    }
}
