import Foundation
import Combine
import BlocksModels

protocol BlockActionsServiceSingleProtocol {
    func delete(contextId: BlockId, blockIds: [BlockId]) -> Bool
    func duplicate(contextId: BlockId, targetId: BlockId, blockIds: [BlockId], position: BlockPosition)
    func replace(contextId: BlockId, blockId: BlockId, info: BlockInformation) -> MiddlewareResponse?
    func add(contextId: BlockId, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId?
    func close(contextId: BlockId, blockId: BlockId)
    func open(contextId: BlockId, blockId: BlockId) -> Bool
    func move(
        contextId: BlockId,
        blockIds: [String],
        targetContextID: BlockId,
        dropTargetID: String,
        position: BlockPosition
    )
}
