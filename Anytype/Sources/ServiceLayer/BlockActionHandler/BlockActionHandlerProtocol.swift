import Foundation
import BlocksModels

protocol BlockActionHandlerProtocol {
    
    func upload(blockId: BlockId, filePath: String)
    func turnIntoPage(blockId: BlockId, completion: @escaping (BlockId?) -> ())
    
    func handleBlockAction(
        _ action: BlockHandlerActionType,
        blockId: BlockId
    )
}
