import Foundation
import Combine
import UIKit
import BlocksModels
import ProtobufMessages

protocol TextServiceProtocol {
    typealias Style = BlockText.Style
    typealias SplitMode = Anytype_Rpc.Block.Split.Request.Mode
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) -> ResponseEvent?
    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) -> ResponseEvent?
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) -> ResponseEvent?
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) -> SplitSuccess?
    
    @discardableResult
    func setForegroundColor(contextId: BlockId, blockId: BlockId, color: String) -> ResponseEvent?
    
    @discardableResult
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> ResponseEvent?    
}
