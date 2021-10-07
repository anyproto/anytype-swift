import Foundation
import Combine
import BlocksModels

protocol BlockActionsServiceSingleProtocol {
    func delete(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<ResponseEvent, Error>
    func duplicate(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: BlockPosition) -> AnyPublisher<ResponseEvent, Error>
    func replace(contextID: BlockId, blockID: BlockId, block: BlockInformation) -> AnyPublisher<ResponseEvent, Error>
    func add(contextID: BlockId, targetID: BlockId, info: BlockInformation, position: BlockPosition) -> Result<ResponseEvent, Error>
    func close(contextId: BlockId, blockId: BlockId)
    func open(contextId: BlockId, blockId: BlockId) -> ResponseEvent?
}
