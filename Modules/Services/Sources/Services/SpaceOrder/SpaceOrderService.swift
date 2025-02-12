import ProtobufMessages


public protocol SpaceOrderServiceProtocol: Sendable {
    func setOrder(spaceViewIdMoved: String, newOrder: [String]) async throws
    func unsetOrder(spaceViewId: String) async throws
}

final class SpaceOrderService: SpaceOrderServiceProtocol, Sendable {
    func setOrder(spaceViewIdMoved: String, newOrder: [String]) async throws {
        try await ClientCommands.spaceSetOrder(.with {
            $0.spaceViewID = spaceViewIdMoved
            $0.spaceViewOrder = newOrder
        }).invoke()
    }
    
    func unsetOrder(spaceViewId: String) async throws {
        try await ClientCommands.spaceUnsetOrder(.with {
            $0.spaceViewID = spaceViewId
        }).invoke()
    }
}
