@testable import Anytype
import BlocksModels

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
    
    func setDivStyle(blockIds: [BlockId], style: BlockDivider.Style) {
        assertionFailure()
    }
    
    func setAlign(blockIds: [BlockId], alignment: LayoutAlignment) {
        assertionFailure()
    }
    
    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func setFields(fields: [Anytype.BlockFields]) {
        assertionFailure()
    }
    
    func setBlockColor(blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func moveTo(blockId: BlockId, targetId: BlockId) {
        assertionFailure()
    }
}
