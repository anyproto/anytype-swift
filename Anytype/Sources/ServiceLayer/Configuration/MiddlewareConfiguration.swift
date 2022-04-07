import ProtobufMessages

struct MiddlewareConfiguration: Hashable {
    let homeBlockID: String
    let archiveBlockID: String
    let profileBlockId: String
    let gatewayURL: String
}

extension MiddlewareConfiguration {
    
    init(response: Anytype_Rpc.Config.Get.Response) {
        self.homeBlockID = response.homeBlockID
        self.archiveBlockID = response.archiveBlockID
        self.profileBlockId = response.profileBlockID
        self.gatewayURL = response.gatewayURL
    }
    
}

extension MiddlewareConfiguration {
    
    static let empty = MiddlewareConfiguration(
        homeBlockID: "",
        archiveBlockID: "",
        profileBlockId: "",
        gatewayURL: ""
    )
    
}
