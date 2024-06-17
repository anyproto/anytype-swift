import ProtobufMessages

public protocol BlockServiceProtocol: AnyObject, Sendable {
    func add(contextId: String, targetId: String, info: BlockInformation, position: BlockPosition) async throws -> String
    func addFirstBlock(contextId: String, info: BlockInformation) async throws -> String
    func delete(contextId: String, blockIds: [String]) async throws
    func duplicate(contextId: String, targetId: String, blockIds: [String], position: BlockPosition) async throws
    func move(contextId: String, blockIds: [String], targetContextID: String, dropTargetID: String, position: BlockPosition) async throws
    
    func setAlign(objectId: String, blockIds: [String], alignment: LayoutAlignment) async throws
    func setBackgroundColor(objectId: String, blockIds: [String], color: MiddlewareColor) async throws
    func setFields(objectId: String, blockId: String, fields: BlockFields) async throws
    func setBlockColor(objectId: String, blockIds: [String], color: MiddlewareColor) async throws
    
    func replace(objectId: String, blockIds: [String], targetId: String) async throws
    func move(objectId: String, blockId: String, targetId: String, position: Anytype_Model_Block.Position) async throws
    func moveToPage(objectId: String, blockId: String, pageId: String) async throws
    func setLinkAppearance(objectId: String, blockIds: [String], appearance: BlockLink.Appearance) async throws
    func changeMarkup(objectId: String, blockIds: [String], markType: MarkupType) async throws
    
    func lastBlockId(from objectId: String) async throws -> String
    
    func convertChildrenToObjects(
        contextId: String,
        blocksIds: [String],
        typeUniqueKey: ObjectTypeUniqueKey,
        templateId: String
    ) async throws -> [String]
    
    func createBlockLink(
        contextId: String,
        targetId: String,
        spaceId: String,
        details: [BundledDetails],
        typeUniqueKey: ObjectTypeUniqueKey,
        position: BlockPosition,
        templateId: String
    ) async throws -> String
}
