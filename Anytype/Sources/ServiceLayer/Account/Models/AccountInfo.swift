import Foundation
import ProtobufMessages

struct AccountInfo {
    let homeObjectID: String
    let archiveObjectID: String
    let profileObjectID: String
    let gatewayURL: String
    let accountSpaceId: String
    let widgetsId: String
}

extension AccountInfo {
    static let empty = AccountInfo(
        homeObjectID: "",
        archiveObjectID: "",
        profileObjectID: "",
        gatewayURL: "",
        accountSpaceId: "",
        widgetsId: ""
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
            widgetsId: widgetsID
        )
    }
}
