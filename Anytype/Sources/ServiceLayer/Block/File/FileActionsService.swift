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
    private let fileService: FileServiceProtocol
    
    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
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
        defer {
            if data.isTemporary {
                try? FileManager.default.removeItem(atPath: data.path)
            }
        }
        try await fileService.uploadFile(path: data.path, contextID: contextID, blockID: blockID)
    }
    
    func uploadImage(spaceId: String, data: FileData) async throws -> Hash {
        defer {
            if data.isTemporary {
                try? FileManager.default.removeItem(atPath: data.path)
            }
        }
        
        return try await fileService.uploadImage(path: data.path, spaceId: spaceId)
    }
    
    func uploadDataAt(source: FileUploadingSource, contextID: BlockId, blockID: BlockId) async throws {
        let data = try await createFileData(source: source)
        try await uploadDataAt(data: data, contextID: contextID, blockID: blockID)
    }
    
    func uploadImage(spaceId: String, source: FileUploadingSource) async throws -> Hash {
        let data = try await createFileData(source: source)
        return try await uploadImage(spaceId: spaceId, data: data)
    }
    
    func clearCache() async throws {
        try await fileService.clearCache()
    }
    
    func nodeUsage() async throws -> NodeUsageInfo {
        return try await fileService.nodeUsage()
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
