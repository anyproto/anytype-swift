import Foundation
import Combine
import BlocksModels
import ProtobufMessages

protocol BlockActionsServiceFileProtocol {
    typealias BlobData = Data
    typealias FileHash = String
    
    func uploadDataAtFilePath(contextID: BlockId, blockID: BlockId, filePath: String) -> AnyPublisher<ResponseEvent, Error>
    func uploadFile(url: String, localPath: String, type: FileContentType, disableEncryption: Bool) -> AnyPublisher<FileHash, Error>
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> AnyPublisher<BlobData, Error>
}
