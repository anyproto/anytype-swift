import Services
import Combine
import AnytypeCore
import Foundation
import PhotosUI
import SwiftUI

enum FileUploadingSource {
    case path(String)
    case itemProvider(NSItemProvider)
}

struct FileData: Equatable {
    let path: String
    let type: UTType
    let sizeInBytes: Int?
    let isTemporary: Bool
}

protocol FileActionsServiceProtocol: Sendable {
    
    func createFileData(source: FileUploadingSource, onlyUniversalTypes: Bool) async throws -> FileData
    func createFileData(photoItem: PhotosPickerItem) async throws -> FileData
    func createFileData(image: UIImage, type: String) throws -> FileData
    func createFileData(fileUrl: URL) throws -> FileData
    
    func uploadDataAt(data: FileData, contextID: String, blockID: String) async throws
    func uploadFileObject(spaceId: String, data: FileData, origin: ObjectOrigin, createTypeWidgetIfMissing: Bool) async throws -> FileDetails
    
    func uploadDataAt(source: FileUploadingSource, contextID: String, blockID: String) async throws
    func uploadImage(spaceId: String, source: FileUploadingSource, origin: ObjectOrigin, createTypeWidgetIfMissing: Bool) async throws -> FileDetails
    
    func nodeUsage() async throws -> NodeUsageInfo
    
    func clearCache() async throws
}
