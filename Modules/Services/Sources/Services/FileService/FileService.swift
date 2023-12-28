import Foundation
import ProtobufMessages
import AnytypeCore

public protocol FileServiceProtocol: AnyObject {
    func uploadFile(path: String, contextID: BlockId, blockID: BlockId) async throws
    func uploadImage(path: String, spaceId: String) async throws -> Hash
    func clearCache() async throws
    func nodeUsage() async throws -> NodeUsageInfo
}

public final class FileService: FileServiceProtocol {
    
    public init() {}
    
    // MARK: - FileServiceProtocol
    
    public func uploadFile(path: String, contextID: BlockId, blockID: BlockId) async throws {
        try await ClientCommands.blockUpload(.with {
            $0.contextID = contextID
            $0.blockID = blockID
            $0.filePath = path
        }).invoke()
    }
    
    public func uploadImage(path: String, spaceId: String) async throws -> Hash {
        let result = try await ClientCommands.fileUpload(.with {
            $0.localPath = path
            $0.type = FileContentType.image.asMiddleware
            $0.disableEncryption = false
            $0.style = .auto
            $0.spaceID = spaceId
        }).invoke()
        
        return try Hash(safeValue: result.hash)
    }
    
    public func clearCache() async throws {
        try await ClientCommands.fileListOffload(.with {
            $0.includeNotPinned = false
        }).invoke()
    }
    
    public func nodeUsage() async throws -> NodeUsageInfo {
        let result = try await ClientCommands.fileNodeUsage().invoke()
        return NodeUsageInfo(from: result)
    }
}
