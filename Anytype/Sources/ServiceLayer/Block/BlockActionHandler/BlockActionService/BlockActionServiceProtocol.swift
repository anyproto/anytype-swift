import Services
import UIKit
import ProtobufMessages
import AnytypeCore

protocol BlockActionServiceProtocol {

    func upload(blockId: String, filePath: String) async throws
    func turnInto(_ style: BlockText.Style, blockId: String) async throws
    func turnIntoPage(blockId: String, spaceId: String) async throws -> String?
    func add(info: BlockInformation, targetBlockId: String, position: BlockPosition, setFocus: Bool) async throws
    func addChild(info: BlockInformation, parentId: String) async throws
    func delete(blockIds: [String])
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, position: BlockPosition, templateId: String) async throws -> String
    func split(
        _ string: NSAttributedString,
        blockId: String,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        range: NSRange,
        newBlockContentType: BlockText.Style
    ) async throws
    
    func setBackgroundColor(blockIds: [String], color: BlockBackgroundColor)
    func setBackgroundColor(blockIds: [String], color: MiddlewareColor)
    func checked(blockId: String, newValue: Bool)
    func duplicate(blockId: String)
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws
    func setTextForced(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws
    func merge(secondBlockId: String) async throws
    func setObjectType(type: ObjectType) async throws
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    
    func bookmarkFetch(blockId: String, url: AnytypeURL)
    func createAndFetchBookmark(
        contextID: String,
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    )
}

extension BlockActionServiceProtocol {
    func add(info: BlockInformation, targetBlockId: String, position: BlockPosition) async throws {
        try await add(info: info, targetBlockId: targetBlockId, position: position, setFocus: true)
    }
}
