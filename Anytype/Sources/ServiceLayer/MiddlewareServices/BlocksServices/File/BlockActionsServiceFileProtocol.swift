import Foundation
import Combine
import BlocksModels
import ProtobufMessages

protocol BlockActionsServiceFileProtocol {
    typealias ContentType = BlockFile.ContentType
    typealias BlobData = Data
    typealias FileHash = String
    
    func uploadDataAtFilePath(contextID: BlockId, blockID: BlockId, filePath: String) -> AnyPublisher<ServiceSuccess, Error>
    func uploadFile(url: String, localPath: String, type: ContentType, disableEncryption: Bool) -> AnyPublisher<FileHash, Error>
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> AnyPublisher<BlobData, Error>
}
