import Combine
import BlocksModels


/// Protocol for Object actions service
protocol ObjectActionsServiceProtocol {
    /// Protocol for convert children to page action.
    /// NOTE: Action supports List context.
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Void, Error>
    
    /// Protocol for set details action.
    /// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
    func setDetails(contextID: BlockId, details: [DetailsContent]) -> AnyPublisher<ServiceSuccess, Error>
    
    // MARK: - Actions Protocols
    /// Protocol for create page action.
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: DetailsInformationModel,
        position: BlockPosition
    ) -> AnyPublisher<ServiceSuccess, Error>
}
