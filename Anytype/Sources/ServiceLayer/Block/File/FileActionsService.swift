import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore
import UniformTypeIdentifiers

final class FileActionsService: FileActionsServiceProtocol {
    
    private enum FileServiceError: Error {
        case typeIdentifierNotFound
    }
    
    private enum Constants {
        static let filesDirectory = "fileServiceCache"
        static var supportedUploadedTypes: [String] = [
            // We are don't support heic and other platform specific types
            // Picture
            UTType.image,
            UTType.ico,
            UTType.icns,
            UTType.png,
            UTType.jpeg,
            UTType.webP,
            UTType.tiff,
            UTType.bmp,
            UTType.svg,
            UTType.rawImage,
            // Video
            UTType.movie,
            UTType.video,
            UTType.quickTimeMovie,
            UTType.mpeg,
            UTType.mpeg2Video,
            UTType.mpeg2TransportStream,
            UTType.mpeg4Movie,
            UTType.appleProtectedMPEG4Video,
            UTType.avi,
            // Audio
            UTType.audio,
            // Other Files
            UTType.item
        ].map { $0.identifier }
    }
    
    // Clear file cache once for app launch
    private static var cacheCleared: Bool = false
    
    init() {
        if !FileActionsService.cacheCleared {
            clearFileCache()
            FileActionsService.cacheCleared = true
        }
    }
    
    func createFileData(source: FileUploadingSource) async throws -> FileData {
        switch source {
        case .path(let path):
            return FileData(path: path, isTemporary: false)
        case .itemProvider(let itemProvider):
            let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
                Constants.supportedUploadedTypes.contains($0)
            }
            guard let typeIdentifier else {
                throw FileServiceError.typeIdentifierNotFound
            }
            let url = try await itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier, directory: tempDirectoryPath())
            return FileData(path: url.relativePath, isTemporary: true)
        }
    }
 
    func uploadDataAt(data: FileData, contextID: BlockId, blockID: BlockId) async throws {
        try await ClientCommands.blockUpload(.with {
            $0.contextID = contextID
            $0.blockID = blockID
            $0.filePath = data.path
        }).invoke()
        
        if data.isTemporary {
            try? FileManager.default.removeItem(atPath: data.path)
        }
    }
    
    func uploadImage(data: FileData) async throws -> Hash {
        let result = try await ClientCommands.fileUpload(.with {
            $0.localPath = data.path
            $0.type = FileContentType.image.asMiddleware
            $0.disableEncryption = false
            $0.style = .auto
        }).invoke()
        
        if data.isTemporary {
            try? FileManager.default.removeItem(atPath: data.path)
        }
        return try Hash(safeValue: result.hash)
    }
    
    func uploadDataAt(source: FileUploadingSource, contextID: BlockId, blockID: BlockId) async throws {
        let data = try await createFileData(source: source)
        try await uploadDataAt(data: data, contextID: contextID, blockID: blockID)
    }
    
    func uploadImage(source: FileUploadingSource) async throws -> Hash {
        let data = try await createFileData(source: source)
        return try await uploadImage(data: data)
    }
    
    func clearCache() async throws {
        try await ClientCommands.fileListOffload(.with {
            $0.includeNotPinned = false
        }).invoke()
    }
    
    func spaceUsage() async throws -> FileLimits {
        let result = try await ClientCommands.fileSpaceUsage().invoke()
        return FileLimits(
            filesCount: Int64(result.usage.filesCount),
            cidsCount: Int64(result.usage.cidsCount),
            bytesUsage: Int64(result.usage.bytesUsage),
            bytesLeft: Int64(result.usage.bytesLeft),
            bytesLimit: Int64(result.usage.bytesLimit),
            localBytesUsage: Int64(result.usage.localBytesUsage)
        )
    }
    
    // MARK: - Private
    
    private func tempDirectoryPath() -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(Constants.filesDirectory, isDirectory: true)
    }
    
    private func clearFileCache() {
        
        let fileManager = FileManager.default
        
        guard let paths = try? fileManager.contentsOfDirectory(at: tempDirectoryPath(), includingPropertiesForKeys: nil) else { return }
        
        for path in paths {
            try? fileManager.removeItem(at: path)
        }
    }
}
