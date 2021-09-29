import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockActionsServiceListProtocol {
    typealias DividerStyle = BlockDivider.Style
    typealias TextStyle = BlockText.Style
    typealias Alignment = LayoutAlignment
    typealias Field = String
    
    func delete(blockIds: [String]) -> AnyPublisher<ResponseEvent, Error>
    func setPageIsArchived(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<ResponseEvent, Error>
    func setDivStyle(contextID: BlockId, blockIds: [BlockId], style: DividerStyle) -> AnyPublisher<ResponseEvent, Error>
    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<ResponseEvent, Error>
    func setBackgroundColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ResponseEvent, Error>
    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: TextStyle) -> AnyPublisher<ResponseEvent, Error>
    func setFields(contextID: BlockId, blockFields: [BlockFields]) -> AnyPublisher<ResponseEvent, Error>
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ResponseEvent, Error>
    
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId) -> ResponseEvent?
}
