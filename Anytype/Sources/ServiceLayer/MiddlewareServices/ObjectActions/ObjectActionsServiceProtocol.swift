import Combine
import BlocksModels
import ProtobufMessages


/// Protocol for Object actions service
protocol ObjectActionsServiceProtocol {
    /// Protocol for convert children to page action.
    /// NOTE: Action supports List context.
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> AnyPublisher<Void, Error>
    
    /// Protocol for set details action.
    /// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
    func setDetails(contextID: BlockId, details: [DetailsKind: DetailsEntry<AnyHashable>]) -> AnyPublisher<ServiceSuccess, Error>
    
    // MARK: - Actions Protocols
    /// Protocol for create page action.
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: [DetailsKind: DetailsEntry<AnyHashable>],
        position: BlockPosition,
        templateID: String
    ) -> AnyPublisher<ServiceSuccess, Error>
    
    @discardableResult
    func move(
        dashboadId: BlockId,
        blockId: BlockId,
        dropPositionblockId: BlockId,
        position: Anytype_Model_Block.Position
    ) -> AnyPublisher<Void, Error>
}
