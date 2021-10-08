import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockListServiceProtocol {
    func delete(blockIds: [String]) -> AnyPublisher<ResponseEvent, Error>
    func setPageIsArchived(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<ResponseEvent, Error>
    func setDivStyle(contextId: BlockId, blockIds: [BlockId], style: BlockDivider.Style) -> ResponseEvent?
    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) -> AnyPublisher<ResponseEvent, Error>
    func setBackgroundColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ResponseEvent, Error>
    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: BlockText.Style) -> AnyPublisher<ResponseEvent, Error>
    func setFields(contextId: BlockId, fields: [BlockFields]) -> ResponseEvent?
    func setBlockColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> ResponseEvent?
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId) -> ResponseEvent?
}
