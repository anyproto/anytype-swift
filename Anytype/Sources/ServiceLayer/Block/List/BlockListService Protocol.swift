import Services
import ProtobufMessages

protocol BlockListServiceProtocol: AnyObject {
    func setAlign(objectId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment)
    func setBackgroundColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) async throws
    func setFields(objectId: BlockId, blockId: BlockId, fields: BlockFields)
    func setBlockColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor)
    
    func replace(objectId: BlockId, blockIds: [BlockId], targetId: BlockId)
    func move(objectId: BlockId, blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position)
    func moveToPage(objectId: BlockId, blockId: BlockId, pageId: BlockId)
    func setLinkAppearance(objectId: BlockId, blockIds: [BlockId], appearance: BlockLink.Appearance) async throws
    func changeMarkup(objectId: BlockId, blockIds: [BlockId], markType: MarkupType) async throws
}
