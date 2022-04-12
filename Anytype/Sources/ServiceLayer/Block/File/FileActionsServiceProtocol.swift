import BlocksModels
import Combine
import AnytypeCore
import ProtobufMessages

protocol FileActionsServiceProtocol {
    
    func syncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId)
    
    func asyncUploadDataAt(filePath: String, contextID: BlockId, blockID: BlockId) -> Future<Anytype_Rpc.Block.Upload.Response, Error>
    
    func syncUploadImageAt(localPath: String) -> Hash?    
}
