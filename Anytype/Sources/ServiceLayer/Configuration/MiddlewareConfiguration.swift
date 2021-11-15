
struct MiddlewareConfiguration: Hashable {
    let homeBlockID: String
    let archiveBlockID: String
    let profileBlockId: String
    let gatewayURL: String
    
    static let empty = MiddlewareConfiguration(
        homeBlockID: "",
        archiveBlockID: "",
        profileBlockId: "",
        gatewayURL: ""
    )
}
