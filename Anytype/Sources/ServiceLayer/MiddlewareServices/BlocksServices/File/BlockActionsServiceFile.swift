import Foundation
import Combine
import BlocksModels
import ProtobufMessages

private extension BlockActionsServiceFile {
    enum PossibleError: Error {
        case uploadFileActionContentTypeConversionHasFailed
    }
}

class BlockActionsServiceFile: BlockActionsServiceFileProtocol {
    /// NOTE: `Upload` action will return message with event `blockSetFile.state == .uploading`.
    func uploadDataAtFilePath(contextID: String, blockID: String, filePath: String) -> AnyPublisher<ServiceSuccess, Error>  {
        Anytype_Rpc.Block.Upload.Service.invoke(contextID: contextID, blockID: blockID, filePath: filePath, url: "")
            .map(\.event).map(ServiceSuccess.init).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
        
    func uploadFile(url: String, localPath: String, type: FileContentType, disableEncryption: Bool) -> AnyPublisher<FileHash, Error> {
        guard let contentType = BlockContentFileContentTypeConverter.asMiddleware(type) else {
            return Fail.init(error: PossibleError.uploadFileActionContentTypeConversionHasFailed).eraseToAnyPublisher()
        }
        return uploadFile(url: url, localPath: localPath, type: contentType, disableEncryption: disableEncryption)
    }
    
    private func uploadFile(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool) -> AnyPublisher<FileHash, Error> {
        Anytype_Rpc.UploadFile.Service.invoke(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption)
            .map(\.hash)
            .subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
        
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> AnyPublisher<BlobData, Error> {
        Anytype_Rpc.Ipfs.Image.Get.Blob.Service.invoke(hash: hash, wantWidth: wantWidth, queue: .global())
            .map(\.blob)
            .subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
}
