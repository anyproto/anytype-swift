@testable import Anytype
import BlocksModels
import ProtobufMessages

final class BlockListServiceMock: BlockListServiceProtocol {
    var replaceStub = false
    var replaceNumberOfCalls = 0
    var replaceBlockIds: [BlockId]?
    var replaceTargetId: BlockId?
    func replace(objectId: BlockId, blockIds: [BlockId], targetId: BlockId) {
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
    func move(objectId: BlockId, blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position) {
        if moveStub {
            moveNumberOfCalls += 1
            moveBlockId = blockId
            moveTargetId = targetId
            movePosition = position
        } else {
            assertionFailure()
        }
    }

    func setAlign(objectId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) {
        assertionFailure()
    }

    func changeMarkup(objectId: BlockId, blockIds: [BlockId], markType: MarkupType) {
        assertionFailure()
    }
    
    func setBackgroundColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func setFields(objectId: BlockId, fields: [BlockFields]) {
        assertionFailure()
    }
    
    func setBlockColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func moveToPage(objectId: BlockId, blockId: BlockId, pageId: BlockId) {
        assertionFailure()
    }

    func setFields(objectId: BlockId, blockId: BlockId, fields: BlockFields) {
        assertionFailure()
    }

    func setLinkAppearance(objectId: BlockId, blockIds: [BlockId], appearance: BlockLink.Appearance) {
        assertionFailure()
    }
}
