import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore

final class BlockActionsServiceFile: BlockActionsServiceFileProtocol {
    
    func syncUploadDataAt(
        filePath: String,
        contextID: BlockId,
        blockID: BlockId
    ) {
        let result = Anytype_Rpc.Block.Upload.Service.invoke(
            contextID: contextID,
            blockID: blockID,
            filePath: filePath,
            url: ""
        )
        
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.blockUpload)
        
        _ = result.getValue()
    }
    
    /// NOTE: `Upload` action will return message with event `blockSetFile.state == .uploading`.
    func asyncUploadDataAt(
        filePath: String,
        contextID: BlockId,
        blockID: BlockId
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
    
    func syncUploadImageAt(localPath: String) -> Hash? {
        let result = Anytype_Rpc.UploadFile.Service.invoke(
            url: "",
            localPath: localPath,
            type: FileContentType.image.asMiddleware,
            disableEncryption: false // Deprecated
        )
        
        switch result {
        case .success(let response):
            return Hash(response.hash)
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func asyncUploadImageAt(localPath: String) -> AnyPublisher<Hash, Error> {
        return Anytype_Rpc.UploadFile.Service.invoke(
            url: "",
            localPath: localPath,
            type: FileContentType.image.asMiddleware,
            disableEncryption: false // Deprecated
        )
            .compactMap { Hash($0.hash) }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
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
