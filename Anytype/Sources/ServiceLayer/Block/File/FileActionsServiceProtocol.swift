import BlocksModels
import Combine
import AnytypeCore
import Foundation

enum FileUploadingSource {
    case path(String)
    case itemProvider(NSItemProvider)
}

struct FileData {
    let path: String
    let isTemporary: Bool
}

protocol FileActionsServiceProtocol {
    
    func createFileData(source: FileUploadingSource) async throws -> FileData
    
    func uploadDataAt(data: FileData, contextID: BlockId, blockID: BlockId) async throws
    func uploadImage(data: FileData) async throws -> Hash
    
    func uploadDataAt(source: FileUploadingSource, contextID: BlockId, blockID: BlockId) async throws
    func uploadImage(source: FileUploadingSource) async throws -> Hash
    
    func clearCache() async throws
}
