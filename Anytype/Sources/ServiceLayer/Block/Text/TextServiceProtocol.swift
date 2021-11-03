import Foundation
import Combine
import UIKit
import BlocksModels
import ProtobufMessages

protocol TextServiceProtocol {
    typealias Style = BlockText.Style
    typealias SplitMode = Anytype_Rpc.Block.Split.Request.Mode
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool)
    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId)
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) -> MiddlewareResponse?
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) -> SplitSuccess?
    
    @discardableResult
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> MiddlewareResponse?    
}
