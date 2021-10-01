import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude

final class BlockActionsServiceFile: BlockActionsServiceFileProtocol {
    
    /// NOTE: `Upload` action will return message with event `blockSetFile.state == .uploading`.
    func uploadDataAtFilePath(
        contextID: String,
        blockID: String,
        filePath: String
    ) -> AnyPublisher<ResponseEvent, Error>  {
        Anytype_Rpc.Block.Upload.Service.invoke(
            contextID: contextID,
            blockID: blockID,
            filePath: filePath,
            url: ""
        )
            .map(\.event)
            .map(ResponseEvent.init)
            .subscribe(on: DispatchQueue.global())
            .handleEvents(
                receiveSubscription: { _ in
                    // Analytics
                    Amplitude.instance().logEvent(AmplitudeEventsName.blockUpload)
                }
            )
            .eraseToAnyPublisher()
    }
    
    func uploadFile(
        url: String,
        localPath: String,
        type: FileContentType,
        disableEncryption: Bool
    ) -> AnyPublisher<Hash, Error> {
        guard let contentType = BlockContentFileContentTypeConverter.asMiddleware(type) else {
            return Fail(
                error: PossibleError.uploadFileActionContentTypeConversionHasFailed
            ).eraseToAnyPublisher()
        }
        return uploadFile(
            url: url,
            localPath: localPath,
            type: contentType,
            disableEncryption: disableEncryption
        )
    }
    
    private func uploadFile(
        url: String,
        localPath: String,
        type: Anytype_Model_Block.Content.File.TypeEnum,
        disableEncryption: Bool
    ) -> AnyPublisher<Hash, Error> {
        Anytype_Rpc.UploadFile.Service.invoke(
            url: url,
            localPath: localPath,
            type: type,
            disableEncryption: disableEncryption
        )
            .compactMap { Hash($0.hash) }
            .subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> AnyPublisher<Data, Error> {
        Anytype_Rpc.Ipfs.Image.Get.Blob.Service.invoke(
            hash: hash,
            wantWidth: wantWidth,
            queue: .global()
        )
            .map(\.blob)
            .subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
}

private extension BlockActionsServiceFile {
    enum PossibleError: Error {
        case uploadFileActionContentTypeConversionHasFailed
    }
}
