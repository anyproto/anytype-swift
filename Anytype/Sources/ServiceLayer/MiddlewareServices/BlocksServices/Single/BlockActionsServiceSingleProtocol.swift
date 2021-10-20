import Foundation
import Combine
import BlocksModels

protocol BlockActionsServiceSingleProtocol {
    func delete(contextId: BlockId, blockIds: [BlockId]) -> ResponseEvent?
    func duplicate(contextId: BlockId, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) -> ResponseEvent?
    func replace(contextId: BlockId, blockId: BlockId, info: BlockInformation) -> ResponseEvent?
    func add(contextId: BlockId, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> ResponseEvent?
    func close(contextId: BlockId, blockId: BlockId)
    func open(contextId: BlockId, blockId: BlockId) -> ResponseEvent?
}
