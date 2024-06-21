import Foundation
import Combine
import ProtobufMessages

public protocol TextServiceProtocol: Sendable {
    typealias Style = BlockText.Style
    typealias SplitMode = Anytype_Rpc.Block.Split.Request.Mode
    
    func checked(contextId: String, blockId: String, newValue: Bool) async throws
    func merge(contextId: String, firstBlockId: String, secondBlockId: String) async throws
    func setStyle(contextId: String, blockId: String, style: Style) async throws
    func split(contextId: String, blockId: String, range: NSRange, style: Style, mode: SplitMode) async throws -> String

    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws
    func setTextForced(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws
    func setTextIcon(
        contextId: String,
        blockId: String,
        imageObjectId: String,
        emojiUnicode: String
    ) async throws
}
