import Combine
import Services
import ProtobufMessages
import AnytypeCore

protocol ObjectActionsServiceProtocol {
    func delete(objectIds: [BlockId], route: RemoveCompletelyRoute) async throws
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool)
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) async throws
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool)
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) async throws
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], typeId: String) -> [BlockId]?
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails])
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) async throws
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue)
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position)
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) async throws
    func setLocked(_ isLocked: Bool, objectId: BlockId)
    func updateLayout(contextID: BlockId, value: Int)
    func duplicate(objectId: BlockId) -> BlockId?
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: [BundledDetails],
        position: BlockPosition,
        templateId: String
    ) -> BlockId?
    
    func addObjectsToCollection(contextId: BlockId, objectIds: [String]) async throws
    
    func setObjectType(objectId: BlockId, objectTypeId: String)
    func setObjectSetType(objectId: BlockId) async throws
    func setObjectCollectionType(objectId: BlockId) async throws
    func applyTemplate(objectId: BlockId, templateId: BlockId)
    func setSource(objectId: BlockId, source: [String]) async throws
    
    func undo(objectId: BlockId) throws
    func redo(objectId: BlockId) throws
    
    func setInternalFlags(contextId: BlockId, internalFlags: [Int]) async throws
}
