import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore 
protocol BlockActionsServiceFileProtocol {
    
    func syncUploadDataAt(
        filePath: String,
        contextID: BlockId,
        blockID: BlockId
    )
    
    func asyncUploadDataAt(
        filePath: String,
        contextID: BlockId,
        blockID: BlockId
    ) -> AnyPublisher<MiddlewareResponse, Error>
    
    func syncUploadImageAt(localPath: String) -> Hash?
    func asyncUploadImageAt(localPath: String) -> AnyPublisher<Hash, Error>
    
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> Result<Data, Error>
}
