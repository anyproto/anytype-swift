@testable import Anytype
import Services
import ProtobufMessages

final class BlockServiceMock: BlockServiceProtocol, @unchecked Sendable {
    var replaceStub = false
    var replaceNumberOfCalls = 0
    var replaceBlockIds: [String]?
    var replaceTargetId: String?
    func replace(objectId: String, blockIds: [String], targetId: String) {
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
    var moveBlockId: String?
    var moveTargetId: String?
    var movePosition: Anytype_Model_Block.Position?
    func move(objectId: String, blockId: String, targetId: String, position: Anytype_Model_Block.Position) {
        if moveStub {
            moveNumberOfCalls += 1
            moveBlockId = blockId
            moveTargetId = targetId
            movePosition = position
        } else {
            assertionFailure()
        }
    }

    func setAlign(objectId: String, blockIds: [String], alignment: LayoutAlignment) {
        assertionFailure()
    }

    func changeMarkup(objectId: String, blockIds: [String], markType: MarkupType) {
        assertionFailure()
    }
    
    func setBackgroundColor(objectId: String, blockIds: [String], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func setFields(objectId: String, fields: [BlockFields]) {
        assertionFailure()
    }
    
    func setBlockColor(objectId: String, blockIds: [String], color: MiddlewareColor) {
        assertionFailure()
    }
    
    func moveToPage(objectId: String, blockId: String, pageId: String) {
        assertionFailure()
    }

    func setFields(objectId: String, blockId: String, fields: BlockFields) {
        assertionFailure()
    }

    func setLinkAppearance(objectId: String, blockIds: [String], appearance: BlockLink.Appearance) {
        assertionFailure()
    }
    
    func lastBlockId(from objectId: String, spaceId: String) async throws -> String {
        ""
    }
    
    func add(contextId: String, targetId: String, info: Services.BlockInformation, position: Services.BlockPosition) async throws -> String {
        assertionFailure()
        return ""
    }
    
    func addFirstBlock(contextId: String, info: BlockInformation) async throws -> String {
        assertionFailure()
        return ""    
    }
    
    
    func delete(contextId: String, blockIds: [String]) async throws {
        assertionFailure()
    }
    
    func duplicate(contextId: String, targetId: String, blockIds: [String], position: Services.BlockPosition) async throws {
        assertionFailure()
    }
    
    func move(contextId: String, blockIds: [String], targetContextID: String, dropTargetID: String, position: Services.BlockPosition) async throws {
        assertionFailure()
    }
    
    func convertChildrenToObjects(contextId: String, blocksIds: [String], typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> [String] {
        assertionFailure()
        return []
    }
    
    func createBlockLink(contextId: String, targetId: String, spaceId: String, details: [Services.BundledDetails], typeUniqueKey: Services.ObjectTypeUniqueKey, position: Services.BlockPosition, templateId: String) async throws -> String {
        assertionFailure()
        return ""
    }
    
    func moveToPage(objectId: String, blockIds: [String], pageId: String) async throws {
        assertionFailure()
    }
}
