import BlocksModels
import Combine
import AnytypeCore

protocol FileActionsServiceProtocol {
    
    func syncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId)
    
    func asyncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId) -> AnyPublisher<EventsBunch, Error>
    
    func syncUploadImageAt(localPath: String) -> Hash?
    func asyncUploadImage(at localPathURL: URL) -> AnyPublisher<Hash?, Error>
}
