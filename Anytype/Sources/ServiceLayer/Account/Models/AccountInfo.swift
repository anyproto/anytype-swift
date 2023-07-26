import Foundation
import ProtobufMessages

struct AccountInfo {
    let homeObjectID: String
    let archiveObjectID: String
    let profileObjectID: String
    let gatewayURL: String
    let accountSpaceId: String
    let workspaceObjectId: String
    let widgetsId: String
    let analyticsId: String
    let deviceId: String
}

extension AccountInfo {
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
