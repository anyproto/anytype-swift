import Foundation
import Combine
import UIKit
import BlocksModels
import ProtobufMessages

protocol TextServiceProtocol {
    typealias Style = BlockText.Style
    typealias SplitMode = Anytype_Rpc.Block.Split.Request.Mode
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool)
    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) -> Bool
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style)
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) -> BlockId?

    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString)

    @discardableResult
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool
}
