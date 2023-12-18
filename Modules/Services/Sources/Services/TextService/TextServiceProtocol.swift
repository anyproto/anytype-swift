import Foundation
import Combine
import ProtobufMessages

public protocol TextServiceProtocol {
    typealias Style = BlockText.Style
    typealias SplitMode = Anytype_Rpc.Block.Split.Request.Mode
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) async throws
    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) async throws
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) async throws
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) async throws -> BlockId

    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws
    func setTextIcon(
        contextId: BlockId,
        blockId: BlockId,
        imageHash: String,
        emojiUnicode: String
    ) async throws
}
