import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockListServiceProtocol {
    func setDivStyle(blockIds: [BlockId], style: BlockDivider.Style)
    func setAlign(blockIds: [BlockId], alignment: LayoutAlignment)
    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor)
    func setFields(fields: [BlockFields])
    func setBlockColor(blockIds: [BlockId], color: MiddlewareColor)
    
    func replace(blockIds: [BlockId], targetId: BlockId)
    func moveTo(blockId: BlockId, targetId: BlockId)
}
