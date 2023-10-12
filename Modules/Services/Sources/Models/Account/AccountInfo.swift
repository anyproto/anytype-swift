import Foundation
import ProtobufMessages

public struct AccountInfo: Equatable {
    public let homeObjectID: String
    public let archiveObjectID: String
    public let profileObjectID: String
    public let gatewayURL: String
    public let accountSpaceId: String
    public let workspaceObjectId: String
    public let widgetsId: String
    public let analyticsId: String
    public let deviceId: String
}

public extension AccountInfo {
    static let empty = AccountInfo(
        homeObjectID: "",
        archiveObjectID: "",
        profileObjectID: "",
        gatewayURL: "",
        accountSpaceId: "",
        workspaceObjectId: "",
        widgetsId: "",
        analyticsId: "",
        deviceId: ""
    )
}

extension Anytype_Model_Account.Info {
    var asModel: AccountInfo {
        return AccountInfo(
            homeObjectID: homeObjectID,
            archiveObjectID: archiveObjectID,
            profileObjectID: profileObjectID,
            gatewayURL: gatewayURL,
            accountSpaceId: accountSpaceID,
            workspaceObjectId: workspaceObjectID,
            widgetsId: widgetsID,
            analyticsId: analyticsID,
            deviceId: deviceID
        )
    }
}
