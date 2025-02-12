@testable import Anytype
import Services
import ProtobufMessages
import XCTest
import Foundation
import AnytypeCore

struct SplitData {
    let string: NSAttributedString
    let blockId: String
    let mode: Anytype_Rpc.Block.Split.Request.Mode
    let range: NSRange
    let newBlockContentType: BlockText.Style
}

final class BlockActionServiceMock: BlockActionServiceProtocol, @unchecked Sendable {
    var splitStub = false
    var splitNumberOfCalls = 0
    var splitData: SplitData?
    func setAndSplit(_ string: SafeNSAttributedString, blockId: String, mode: Anytype_Rpc.Block.Split.Request.Mode, range: NSRange, newBlockContentType: BlockText.Style) {
        if splitStub {
            splitNumberOfCalls += 1
            splitData = .init(
                string: string.value,
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
    var turnIntoBlockId: String?
    func turnInto(_ style: BlockText.Style, blockId: String) {
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
    var addChildParentId: String?
    func addChild(info: BlockInformation, parentId: String) {
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
    var addTargetBlockId: String?
    var addPosition: BlockPosition?
    var addSetFocus: Bool?
    func add(info: BlockInformation, targetBlockId: String, position: BlockPosition, setFocus: Bool) {
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
    var deleteBlocksId: [String]?
    func delete(blockIds: [String]) {
        if deleteStub { 
            deleteNumberOfCalls += 1
            deleteBlocksId = blockIds
        } else {
            assertionFailure()
        }
    }
    
    var mergeStub = false
    var mergeNumberOfCalls = 0
    var mergeSecondBlockId: String?
    func merge(secondBlockId: String) {
        if mergeStub {
            mergeNumberOfCalls += 1
            mergeSecondBlockId = secondBlockId
        }
    }
    
    func upload(blockId: String, filePath: String) {
        assertionFailure()
    }
    
    func turnIntoObject(blockId: String, spaceId: String) async throws -> String? {
        assertionFailure()
        return nil
    }
    
    func createPage(
        targetId: String,
        spaceId: String,
        typeUniqueKey: ObjectTypeUniqueKey,
        position: BlockPosition,
        templateId: String
    ) async throws -> String {
        assertionFailure()
        return "nil"
    }
    
    func bookmarkFetch(blockId: String, url: AnytypeURL) {
        assertionFailure()
    }
    
    func setBackgroundColor(blockIds: [String], color: BlockBackgroundColor) {
        assertionFailure()
    }

    func setBackgroundColor(blockIds: [String], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func checked(blockId: String, newValue: Bool) {
        assertionFailure()
    }
    
    func duplicate(blockId: String) {
        assertionFailure()
    }
    
    func setObjectSetType() async throws {
        assertionFailure()
    }
    
    func setObjectCollectionType() async throws {
        assertionFailure()
    }
    
    func setFields(blockFields: [BlockFields]) {
        assertionFailure()
    }
    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) {
        assertionFailure()
    }
    
    func setTextForced(contextId: String, blockId: String, middlewareString: MiddlewareString) {
        assertionFailure()
    }
    
    func setObjectType(type: ObjectType) async throws {
        assertionFailure()
    }
    
    func createAndFetchBookmark(contextID: String, targetID: String, position: BlockPosition, url: AnytypeURL) {
        assertionFailure()
    }

    func setFields(blockFields: BlockFields, blockId: String) {
        assertionFailure()
    }
}
