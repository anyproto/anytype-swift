import Foundation
import ProtobufMessages
import AnytypeCore

public protocol FileServiceProtocol: AnyObject, Sendable {
    func uploadFileBlock(path: String, contextID: String, blockID: String) async throws
    func uploadFileObject(path: String, spaceId: String, origin: ObjectOrigin) async throws -> FileDetails
    func preloadFileObject(path: String, spaceId: String, origin: ObjectOrigin) async throws -> String
    func uploadPreloadedFileObject(fileId: String, spaceId: String, origin: ObjectOrigin) async throws -> FileDetails
    func discardPreloadFile(fileId: String, spaceId: String) async throws
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
            $0.preloadOnly = false
        }).invoke()
        return FileDetails(objectDetails: try ObjectDetails(protobufStruct: result.details))
    }

    public func preloadFileObject(path: String, spaceId: String, origin: ObjectOrigin) async throws -> String {
        let result = try await ClientCommands.fileUpload(.with {
            $0.localPath = path
            
            $0.disableEncryption = false
            $0.style = .auto
            $0.spaceID = spaceId
            $0.origin = origin
            $0.preloadOnly = true
        }).invoke()
        return result.preloadFileID
    }

    public func uploadPreloadedFileObject(fileId: String, spaceId: String, origin: ObjectOrigin) async throws -> FileDetails {
        let result = try await ClientCommands.fileUpload(.with {
            $0.preloadFileID = fileId
            
            $0.disableEncryption = false
            $0.style = .auto
            $0.spaceID = spaceId
            $0.origin = origin
            $0.preloadOnly = false
        }).invoke()
        return FileDetails(objectDetails: try ObjectDetails(protobufStruct: result.details))
    }

    public func discardPreloadFile(fileId: String, spaceId: String) async throws {
        try await ClientCommands.fileDiscardPreload(.with {
            $0.fileID = fileId
            $0.spaceID = spaceId
        }).invoke()
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
