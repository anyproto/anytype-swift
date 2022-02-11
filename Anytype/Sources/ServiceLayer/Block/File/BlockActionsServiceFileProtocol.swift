import BlocksModels
import Combine
import AnytypeCore

protocol BlockActionsServiceFileProtocol {
    
    func syncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId)
    
    func asyncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId) -> AnyPublisher<EventsBunch, Error>
    
    func syncUploadImageAt(localPath: String) -> Hash?    
}
