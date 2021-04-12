import Foundation

enum MiddlewareModels{}

/// Middleware configuration
/// TODO: Move to BlockModels module.
extension MiddlewareModels {
    struct Configuration: Hashable {
        let homeBlockID: String
        let archiveBlockID: String
        let profileBlockId: String
        let gatewayURL: String
    }
    struct Version: Hashable {
        let version: String
    }
}
