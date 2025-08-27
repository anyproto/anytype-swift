import Combine
import ProtobufMessages
import AnytypeCore

public protocol ObjectActionsServiceProtocol: Sendable {
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
    
    func delete(objectIds: [String]) async throws
    func setArchive(objectIds: [String], _ isArchived: Bool) async throws
    func setPin(objectIds: [String], _ isPinned: Bool) async throws

    func setLocked(_ isLocked: Bool, objectId: String) async throws
    func updateLayout(contextID: String, value: Int) async throws
    func duplicate(objectId: String) async throws -> String
    func applyTemplate(objectId: String, templateId: String) async throws
    
    func updateBundledDetails(contextID: String, details: [BundledDetails]) async throws
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws
    func setInternalFlags(contextId: String, internalFlags: [Int]) async throws
    
    func addObjectsToCollection(contextId: String, objectIds: [String]) async throws
    func setObjectType(objectId: String, typeUniqueKey: ObjectTypeUniqueKey) async throws
    func setObjectSetType(objectId: String) async throws
    func setObjectCollectionType(objectId: String) async throws
    func setSource(objectId: String, source: [String]) async throws
    
    func undo(objectId: String) async throws
    func redo(objectId: String) async throws
    
    func move(dashboadId: String, blockId: String, dropPositionblockId: String, position: Anytype_Model_Block.Position) async throws
    
    func createSet(name: String, iconEmoji: Emoji?, setOfObjectType: String, spaceId: String) async throws -> ObjectDetails
}
