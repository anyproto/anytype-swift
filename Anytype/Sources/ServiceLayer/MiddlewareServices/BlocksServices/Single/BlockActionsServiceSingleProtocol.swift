import Foundation
import Combine
import BlocksModels

protocol BlockActionsServiceSingleProtocol {
    func delete(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<ServiceSuccess, Error>
    func duplicate(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: BlockPosition) -> AnyPublisher<ServiceSuccess, Error>
    func replace(contextID: BlockId, blockID: BlockId, block: BlockInformation) -> AnyPublisher<ServiceSuccess, Error>
    func add(contextID: BlockId, targetID: BlockId, info: BlockInformation, position: BlockPosition) -> AnyPublisher<ServiceSuccess, Error>
    func close(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error>
    func open(contextID: BlockId, blockID: BlockId) -> AnyPublisher<ServiceSuccess, Error>
}
