import Combine
import ProtobufMessages
import AnytypeCore

public protocol ObjectActionsServiceProtocol {
    func createObject(
        name: String,
        typeUniqueKey: ObjectTypeUniqueKey,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        origin: ObjectOrigin,
        templateId: String?
    ) async throws -> ObjectDetails
    
    func delete(objectIds: [BlockId]) async throws
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) async throws
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) async throws

    func setLocked(_ isLocked: Bool, objectId: BlockId) async throws
    func updateLayout(contextID: BlockId, value: Int) async throws
    func duplicate(objectId: BlockId) async throws -> BlockId
    func applyTemplate(objectId: BlockId, templateId: BlockId) async throws
    
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) async throws
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws
    func setInternalFlags(contextId: BlockId, internalFlags: [Int]) async throws
    
    func addObjectsToCollection(contextId: BlockId, objectIds: [String]) async throws
    func setObjectType(objectId: BlockId, typeUniqueKey: ObjectTypeUniqueKey) async throws
    func setObjectSetType(objectId: BlockId) async throws
    func setObjectCollectionType(objectId: BlockId) async throws
    func setSource(objectId: BlockId, source: [String]) async throws
    
    func undo(objectId: BlockId) async throws
    func redo(objectId: BlockId) async throws
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) async throws
}
