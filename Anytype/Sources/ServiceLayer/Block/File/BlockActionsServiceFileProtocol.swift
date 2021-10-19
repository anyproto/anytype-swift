import BlocksModels
import Combine
import AnytypeCore

protocol BlockActionsServiceFileProtocol {
    
    func syncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId)
    
    func asyncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId) -> AnyPublisher<MiddlewareResponse, Error>
    
    func syncUploadImageAt(localPath: String) -> Hash?
    
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> Result<Data, Error>
}
