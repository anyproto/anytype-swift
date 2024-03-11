import ProtobufMessages

public protocol BlockServiceProtocol: AnyObject {
    func add(contextId: String, targetId: BlockId, info: BlockInformation, position: BlockPosition) async throws -> BlockId
    func delete(contextId: String, blockIds: [BlockId]) async throws
    func duplicate(contextId: String, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) async throws
    func move(contextId: String, blockIds: [String], targetContextID: BlockId, dropTargetID: String, position: BlockPosition) async throws
    
    func setAlign(objectId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) async throws
    func setBackgroundColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) async throws
    func setFields(objectId: BlockId, blockId: BlockId, fields: BlockFields) async throws
    func setBlockColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) async throws
    
    func replace(objectId: BlockId, blockIds: [BlockId], targetId: BlockId) async throws
    func move(objectId: BlockId, blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position) async throws
    func moveToPage(objectId: BlockId, blockId: BlockId, pageId: BlockId) async throws
    func setLinkAppearance(objectId: BlockId, blockIds: [BlockId], appearance: BlockLink.Appearance) async throws
    func changeMarkup(objectId: BlockId, blockIds: [BlockId], markType: MarkupType) async throws
    
    func lastBlockId(from objectId: BlockId) async throws -> BlockId
    
    func convertChildrenToPages(contextId: BlockId, blocksIds: [BlockId], typeUniqueKey: ObjectTypeUniqueKey) async throws -> [BlockId]
    func createBlockLink(
        contextId: BlockId,
        targetId: BlockId,
        spaceId: String,
        details: [BundledDetails],
        typeUniqueKey: ObjectTypeUniqueKey,
        position: BlockPosition,
        templateId: String
    ) async throws -> BlockId
}
