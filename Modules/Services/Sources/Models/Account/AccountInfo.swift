import Foundation
import ProtobufMessages

public struct AccountInfo: Equatable, Hashable, Sendable, Identifiable, Codable {
    public let homeObjectID: String
    public let archiveObjectID: String
    public let profileObjectID: String
    public let gatewayURL: String
    public let accountSpaceId: String
    public let spaceViewId: String
    public let widgetsId: String
    public let analyticsId: String
    public let deviceId: String
    public let networkId: String
    public let techSpaceId: String
    public let ethereumAddress: String
    
    
    public var id: Int { hashValue }
}

public extension AccountInfo {
    static let empty = AccountInfo(
        homeObjectID: "",
        archiveObjectID: "",
        profileObjectID: "",
        gatewayURL: "",
        accountSpaceId: "",
        spaceViewId: "",
        widgetsId: "",
        analyticsId: "",
        deviceId: "",
        networkId: "",
        techSpaceId: "",
        ethereumAddress: ""
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
            spaceViewId: spaceViewID,
            widgetsId: widgetsID,
            analyticsId: analyticsID,
            deviceId: deviceID,
            networkId: networkID,
            techSpaceId: techSpaceID,
            ethereumAddress: ethereumAddress
        )
    }
}
