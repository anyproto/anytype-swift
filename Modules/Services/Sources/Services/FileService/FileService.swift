import Foundation
import ProtobufMessages
import AnytypeCore

public protocol FileServiceProtocol: AnyObject {
    func uploadFileBlock(path: String, contextID: String, blockID: String) async throws
    func uploadFileObject(path: String, spaceId: String, origin: ObjectOrigin) async throws -> FileDetails
    func clearCache() async throws
    func nodeUsage() async throws -> NodeUsageInfo
}

final class FileService: FileServiceProtocol {
    
    // MARK: - FileServiceProtocol
    
    public func uploadFileBlock(path: String, contextID: String, blockID: String) async throws {
        try await ClientCommands.blockUpload(.with {
            $0.contextID = contextID
            $0.blockID = blockID
            $0.filePath = path
        }).invoke()
    }
    
    public func uploadFileObject(path: String, spaceId: String, origin: ObjectOrigin) async throws -> FileDetails {
        let result = try await ClientCommands.fileUpload(.with {
            $0.localPath = path
            $0.disableEncryption = false
            $0.style = .auto
            $0.spaceID = spaceId
            $0.origin = origin
        }).invoke()
        return FileDetails(objectDetails: try ObjectDetails(protobufStruct: result.details))
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
