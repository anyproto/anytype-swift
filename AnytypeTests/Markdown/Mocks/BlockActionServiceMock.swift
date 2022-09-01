@testable import Anytype
import BlocksModels
import ProtobufMessages
import XCTest
import Foundation

struct SplitData {
    let string: NSAttributedString
    let blockId: BlockId
    let mode: Anytype_Rpc.Block.Split.Request.Mode
    let range: NSRange
    let newBlockContentType: BlockText.Style
}

final class BlockActionServiceMock: BlockActionServiceProtocol {
    var splitStub = false
    var splitNumberOfCalls = 0
    var splitData: SplitData?
    func split(_ string: NSAttributedString, blockId: BlockId, mode: Anytype_Rpc.Block.Split.Request.Mode, range: NSRange, newBlockContentType: BlockText.Style) {
        if splitStub {
            splitNumberOfCalls += 1
            splitData = .init(
                string: string,
                blockId: blockId,
                mode: mode,
                range: range,
                newBlockContentType: newBlockContentType
            )
        } else {
            XCTFail()
        }
    }
    
    var turnIntoStub = false
    var turnIntoNumberOfCalls = 0
    var turnIntoStyle: BlockText.Style?
    var turnIntoBlockId: BlockId?
    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        if turnIntoStub {
            turnIntoNumberOfCalls += 1
            turnIntoStyle = style
            turnIntoBlockId = blockId
        } else {
            assertionFailure()
        }
    }
    
    var addChildStub = false
    var addChildNumberOfCalls = 0
    var addChildInfo: BlockInformation?
    var addChildParentId: BlockId?
    func addChild(info: BlockInformation, parentId: BlockId) {
        if addChildStub {
            addChildNumberOfCalls += 1
            addChildInfo = info
            addChildParentId = parentId
        } else {
            assertionFailure()
        }
    }
    
    var addStub = false
    var addNumberOfCalls = 0
    var addInfo: BlockInformation?
    var addTargetBlockId: BlockId?
    var addPosition: BlockPosition?
    var addSetFocus: Bool?
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool) {
        if addStub {
            addNumberOfCalls += 1
            addInfo = info
            addTargetBlockId = targetBlockId
            addPosition = position
            addSetFocus = setFocus
        } else {
            assertionFailure()
        }
    }
    
    var deleteStub = false
    var deleteNumberOfCalls = 0
    var deleteBlocksId: [BlockId]?
    func delete(blockIds: [BlockId]) {
        if deleteStub { 
            deleteNumberOfCalls += 1
            deleteBlocksId = blockIds
        } else {
            assertionFailure()
        }
    }
    
    var mergeStub = false
    var mergeNumberOfCalls = 0
    var mergeSecondBlockId: BlockId?
    func merge(secondBlockId: BlockId) {
        if mergeStub {
            mergeNumberOfCalls += 1
            mergeSecondBlockId = secondBlockId
        } else {
            XCTFail()
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        assertionFailure()
    }
    
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func createPage(targetId: BlockId, type: ObjectTypeUrl, position: BlockPosition) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func bookmarkFetch(blockId: BlockId, url: AnytypeURL) {
        assertionFailure()
    }
    
    func setBackgroundColor(blockIds: [BlockId], color: BlockBackgroundColor) {
        assertionFailure()
    }

    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        assertionFailure()
    }
    
    func duplicate(blockId: BlockId) {
        assertionFailure()
    }
    
    func setFields(blockFields: [BlockFields]) {
        assertionFailure()
    }
    
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) {
        assertionFailure()
    }
    
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool {
        assertionFailure()
        return false
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        assertionFailure()
    }
    
    func createAndFetchBookmark(contextID: BlockId, targetID: BlockId, position: BlockPosition, url: String) {
        assertionFailure()
    }

    func setFields(blockFields: BlockFields, blockId: BlockId) {
        assertionFailure()
    }

    func setObjectSetType() -> BlockId {
        assertionFailure()
        return ""
    }
}
