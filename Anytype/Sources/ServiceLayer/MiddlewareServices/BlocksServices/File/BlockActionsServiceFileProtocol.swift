import Foundation
import Combine
import BlocksModels
import ProtobufMessages

protocol BlockActionsServiceFileProtocol {
    
    func uploadDataAtFilePath(
        contextID: BlockId,
        blockID: BlockId,
        filePath: String
    ) -> AnyPublisher<ResponseEvent, Error>
    
    func syncUploadImageAt(localPath: String) -> Hash?
    func asyncUploadImageAt(localPath: String) -> AnyPublisher<Hash, Error>
    
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> AnyPublisher<Data, Error>
}
