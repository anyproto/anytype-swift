import Foundation
import Combine
import BlocksModels
import ProtobufMessages

protocol BlockActionsServiceSingleProtocol {
    func paste(contextId: BlockId,
               focusedBlockId: BlockId,
               selectedTextRange: NSRange,
               selectedBlockIds: [BlockId],
               isPartOfBlock: Bool,
               textSlot: String?,
               htmlSlot: String?,
               anySlots: [Anytype_Model_Block]?,
               fileSlots: [Anytype_Rpc.Block.Paste.Request.File]?) -> BlockId?
    func copy(contextId: BlockId, blocksInfo: [BlockInformation], selectedTextRange: NSRange) -> [PasteboardSlot]?
    func delete(contextId: BlockId, blockIds: [BlockId]) -> Bool
    func duplicate(contextId: BlockId, targetId: BlockId, blockIds: [BlockId], position: BlockPosition)
    func add(contextId: BlockId, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId?
    func close(contextId: BlockId, blockId: BlockId)
    func open(contextId: BlockId, blockId: BlockId) -> Bool
    func move(
        contextId: BlockId,
        blockIds: [String],
        targetContextID: BlockId,
        dropTargetID: String,
        position: BlockPosition
    )
}
