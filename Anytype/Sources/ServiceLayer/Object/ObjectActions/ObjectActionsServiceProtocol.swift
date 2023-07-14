import Combine
import Services
import ProtobufMessages
import AnytypeCore

protocol ObjectActionsServiceProtocol {
    func delete(objectIds: [BlockId], route: RemoveCompletelyRoute) async throws
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) async throws
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) async throws
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], typeId: String) async throws -> [BlockId]
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) async throws
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) async throws
    func setLocked(_ isLocked: Bool, objectId: BlockId) async throws
    func updateLayout(contextID: BlockId, value: Int) async throws
    func duplicate(objectId: BlockId) async throws -> BlockId
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: [BundledDetails],
        position: BlockPosition,
        templateId: String
    ) async throws -> BlockId
    
    func addObjectsToCollection(contextId: BlockId, objectIds: [String]) async throws
    
    func setObjectType(objectId: BlockId, objectTypeId: String) async throws
    func setObjectSetType(objectId: BlockId) async throws
    func setObjectCollectionType(objectId: BlockId) async throws
    func applyTemplate(objectId: BlockId, templateId: BlockId) async throws
    func setSource(objectId: BlockId, source: [String]) async throws
    
    func undo(objectId: BlockId) async throws
    func redo(objectId: BlockId) async throws
    
    func setInternalFlags(contextId: BlockId, internalFlags: [Int]) async throws
}
