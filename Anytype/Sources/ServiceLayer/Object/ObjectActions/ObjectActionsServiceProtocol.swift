import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

protocol ObjectActionsServiceProtocol {
    func delete(objectIds: [BlockId], completion: @escaping (Bool) -> ())
    
    func setArchive(objectId: BlockId, _ isArchived: Bool)
    func setArchive(objectIds: [BlockId], _ isArchived: Bool)
    func setFavorite(objectId: BlockId, _ isFavorite: Bool)
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> [BlockId]?
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails])
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue)
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position)
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
    
    func setObjectType(objectId: BlockId, objectTypeId: String)
    func setObjectSetType(objectId: BlockId) -> BlockId
    func applyTemplate(objectId: BlockId, templateId: BlockId)
    
    func undo(objectId: BlockId) throws
    func redo(objectId: BlockId) throws
    
    func setInternalFlags(contextId: BlockId, internalFlags: [Int]) async throws
}
