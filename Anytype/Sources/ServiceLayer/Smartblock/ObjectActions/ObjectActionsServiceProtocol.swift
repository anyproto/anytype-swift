import Combine
import BlocksModels
import ProtobufMessages

protocol ObjectActionsServiceProtocol {
    func setArchive(objectId: String, _ isArchived: Bool)
    func setFavorite(objectId: String, _ isFavorite: Bool)
    
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> [BlockId]?
    
    func setDetails(contextID: BlockId, details: ObjectRawDetails) -> MiddlewareResponse?
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: ObjectRawDetails,
        position: BlockPosition,
        templateID: String
    ) -> CreatePageResponse?
    
    @discardableResult
    func move(
        dashboadId: BlockId,
        blockId: BlockId,
        dropPositionblockId: BlockId,
        position: Anytype_Model_Block.Position
    ) -> MiddlewareResponse?
}
