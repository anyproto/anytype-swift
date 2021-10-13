import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockListServiceProtocol {
    func delete(blockIds: [String]) -> MiddlewareResponse?
    func setDivStyle(contextId: BlockId, blockIds: [BlockId], style: BlockDivider.Style) -> MiddlewareResponse?
    func setAlign(contextId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) -> MiddlewareResponse?
    func setBackgroundColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> MiddlewareResponse?
    func setTextStyle(contextId: BlockId, blockIds: [BlockId], style: BlockText.Style) -> AnyPublisher<MiddlewareResponse, Error>
    func setFields(contextId: BlockId, fields: [BlockFields]) -> MiddlewareResponse?
    func setBlockColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> MiddlewareResponse?
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId) -> MiddlewareResponse?
}
