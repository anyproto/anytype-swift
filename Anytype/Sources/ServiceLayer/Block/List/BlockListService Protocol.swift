import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockListServiceProtocol {
    func setDivStyle(contextId: BlockId, blockIds: [BlockId], style: BlockDivider.Style)
    func setAlign(contextId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment)
    func setBackgroundColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor)
    func setFields(contextId: BlockId, fields: [BlockFields])
    func setBlockColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor)
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId)
}
