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
    ) -> AnyPublisher<MiddlewareResponse, Error>  {
        Anytype_Rpc.Block.Upload.Service.invoke(
            contextID: contextID,
            blockID: blockID,
            filePath: filePath,
            url: ""
        )
            .map(\.event)
            .map(MiddlewareResponse.init)
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
        Anytype_Rpc.UploadFile.Service.invoke(
            url: "",
            localPath: localPath,
            type: FileContentType.image.asMiddleware,
            disableEncryption: false // Deprecated
        )
            .getValue()
            .flatMap { Hash($0.hash) }
    }
    
    func fetchImageAsBlob(hash: String, wantWidth: Int32) -> Result<Data, Error> {
        Anytype_Rpc.Ipfs.Image.Get.Blob.Service.invoke(hash: hash, wantWidth: wantWidth)
            .map(\.blob)
    }
}
