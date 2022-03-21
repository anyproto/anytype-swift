import Foundation
import Combine
import BlocksModels
import ProtobufMessages

protocol BlockActionsServiceSingleProtocol {
    func paste(
        focusedBlockId: BlockId,
        selectedTextRange: NSRange,
        selectedBlockIds: [BlockId],
        isPartOfBlock: Bool,
        textSlot: String?,
        htmlSlot: String?,
        anySlots: [Anytype_Model_Block]?,
        fileSlots: [Anytype_Rpc.Block.Paste.Request.File]?
    ) -> BlockId?
    
    func copy(blocksInfo: [BlockInformation], selectedTextRange: NSRange) -> [PasteboardSlot]?
    func delete(blockIds: [BlockId]) -> Bool
    func duplicate(targetId: BlockId, blockIds: [BlockId], position: BlockPosition)
    func add(targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId?
    func close()
    func open() -> Bool
    func move(blockIds: [String], targetContextID: BlockId, dropTargetID: String, position: BlockPosition)
}
