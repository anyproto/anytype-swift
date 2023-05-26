import Foundation
import Combine
import Services
import ProtobufMessages

protocol BlockActionsServiceSingleProtocol: AnyObject {
    func delete(contextId: String, blockIds: [BlockId]) -> Bool
    func duplicate(contextId: String, targetId: BlockId, blockIds: [BlockId], position: BlockPosition)
    func add(contextId: String, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId?
    func close(contextId: String) async throws
    func open(contextId: String) async throws -> ObjectViewModel
    func openForPreview(contextId: String) async throws -> ObjectViewModel
    func move(contextId: String, blockIds: [String], targetContextID: BlockId, dropTargetID: String, position: BlockPosition)
}
