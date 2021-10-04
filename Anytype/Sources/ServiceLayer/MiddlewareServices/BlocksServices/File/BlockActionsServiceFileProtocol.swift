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
    
    func uploadFile(
        url: String,
        localPath: String,
        type: FileContentType,
        disableEncryption: Bool
    ) -> AnyPublisher<Hash, Error>
    
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> AnyPublisher<Data, Error>
}
