import Foundation

/// Middleware configuration
/// TODO: Move to BlockModels module.
struct MiddlewareConfiguration: Hashable {
    let homeBlockID: String
    let archiveBlockID: String
    let profileBlockId: String
    let gatewayURL: String
}

struct MiddlewareVersion: Hashable {
    let version: String
}
