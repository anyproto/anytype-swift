@testable import Anytype
import BlocksModels
import ProtobufMessages

final class BlockListServiceMock: BlockListServiceProtocol {
    var replaceStub = false
    var replaceNumberOfCalls = 0
    var replaceBlockIds: [BlockId]?
    var replaceTargetId: BlockId?
    func replace(blockIds: [BlockId], targetId: BlockId) {
        if replaceStub {
            replaceNumberOfCalls += 1
            replaceBlockIds = blockIds
            replaceTargetId = targetId
        } else {
            assertionFailure()
        }
    }
    
    var moveStub = false
    var moveNumberOfCalls = 0
    var moveBlockId: BlockId?
    var moveTargetId: BlockId?
    var movePosition: Anytype_Model_Block.Position?
    func move(blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position) {
        if moveStub {
            moveNumberOfCalls += 1
            moveBlockId = blockId
            moveTargetId = targetId
            movePosition = position
        } else {
            assertionFailure()
        }
    }
    
    func setDivStyle(blockIds: [BlockId], style: BlockDivider.Style) {
        assertionFailure()
    }
    
    func setAlign(blockIds: [BlockId], alignment: LayoutAlignment) {
        assertionFailure()
    }
    
    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func setFields(fields: [BlockFields]) {
        assertionFailure()
    }
    
    func setBlockColor(blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        assertionFailure()
    }

    func setFields(fields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) {
        assertionFailure()
    }
}
