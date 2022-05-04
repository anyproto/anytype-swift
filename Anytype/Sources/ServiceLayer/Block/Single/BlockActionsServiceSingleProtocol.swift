import Foundation
import Combine
import BlocksModels
import ProtobufMessages

protocol BlockActionsServiceSingleProtocol {
    func delete(blockIds: [BlockId]) -> Bool
    func duplicate(targetId: BlockId, blockIds: [BlockId], position: BlockPosition)
    func add(targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId?
    func close()
    func open() -> Bool
    func move(blockIds: [String], targetContextID: BlockId, dropTargetID: String, position: BlockPosition)
}
