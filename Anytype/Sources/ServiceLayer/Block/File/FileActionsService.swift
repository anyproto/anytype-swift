import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore

final class FileActionsService: FileActionsServiceProtocol {
    
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
        _ = result.getValue(domain: .blockActionsService)
    }
    
    /// NOTE: `Upload` action will return message with event `blockSetFile.state == .uploading`.
    func asyncUploadDataAt(
        filePath: String,
        contextID: BlockId,
        blockID: BlockId
    ) -> AnyPublisher<EventsBunch, Error>  {
        Anytype_Rpc.Block.Upload.Service.invoke(
            contextID: contextID,
            blockID: blockID,
            filePath: filePath,
            url: ""
        )
            .map(\.event)
            .map(EventsBunch.init)
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func syncUploadImageAt(localPath: String) -> Hash? {
        Anytype_Rpc.UploadFile.Service.invoke(
            url: "",
            localPath: localPath,
            type: FileContentType.image.asMiddleware,
            disableEncryption: false,
            style: .auto
        )
            .getValue(domain: .blockActionsService)
            .flatMap { Hash($0.hash) }
    }
    
}
