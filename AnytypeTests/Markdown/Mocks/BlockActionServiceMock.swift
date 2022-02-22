@testable import Anytype
import BlocksModels
import ProtobufMessages

struct SplitData {
    let string: NSAttributedString
    let blockId: BlockId
    let mode: Anytype_Rpc.Block.Split.Request.Mode
    let position: Int
    let newBlockContentType: BlockText.Style
}

final class BlockActionServiceMock: BlockActionServiceProtocol {
    
    var splitStub = false
    var splitNumberOfCalls = 0
    var splitData: SplitData?
    func split(_ string: NSAttributedString, blockId: BlockId, mode: Anytype_Rpc.Block.Split.Request.Mode, position: Int, newBlockContentType: BlockText.Style) {
        if splitStub {
            splitNumberOfCalls += 1
            splitData = .init(
                string: string,
                blockId: blockId,
                mode: mode,
                position: position,
                newBlockContentType: newBlockContentType
            )
        } else {
            assertionFailure()
        }
    }
    
    
    func upload(blockId: BlockId, filePath: String) {
        assertionFailure()
    }
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        assertionFailure()
    }
    
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition) {
        assertionFailure()
    }
    
    func addChild(info: BlockInformation, parentId: BlockId) {
        assertionFailure()
    }
    
    func delete(blockId: BlockId) {
        assertionFailure()
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func bookmarkFetch(blockId: BlockId, url: String) {
        assertionFailure()
    }
    
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor) {
        assertionFailure()
    }
    
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor) {
        assertionFailure()
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        assertionFailure()
    }
    
    func duplicate(blockId: BlockId) {
        assertionFailure()
    }
    
    func setFields(contextID: BlockId, blockFields: [Anytype.BlockFields]) {
        assertionFailure()
    }
    
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) {
        assertionFailure()
    }
    
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool {
        assertionFailure()
        return false
    }
    
    func merge(secondBlockId: BlockId) {
        assertionFailure()
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        assertionFailure()
    }
    
    func createAndFetchBookmark(contextID: BlockId, targetID: BlockId, position: BlockPosition, url: String) {
        assertionFailure()
    }
    
    
}
