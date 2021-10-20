import Combine
import BlocksModels
import ProtobufMessages

protocol ObjectActionsServiceProtocol {
    func setArchive(objectId: String, _ isArchived: Bool)
    func setFavorite(objectId: String, _ isFavorite: Bool)
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> [BlockId]?
    func setDetails(contextID: BlockId, details: ObjectRawDetails)
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position)
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: ObjectRawDetails,
        position: BlockPosition,
        templateId: String
    ) -> CreatePageResponse?
}
