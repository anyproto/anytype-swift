import Foundation
import _PhotosUI_SwiftUI
import Services
import PhotosUI
import UIKit
import Factory
import AnytypeCore

@MainActor
protocol AttachmentProcessor: AnyObject {
    associatedtype Input
    func process(_ input: Input, spaceId: String) throws -> ChatLinkedObject
}

@MainActor
protocol AsyncAttachmentProcessor: AnyObject {
    associatedtype Input
    func process(_ input: Input, spaceId: String) async throws -> ChatLinkedObject
}

@MainActor
final class FileAttachmentProcessor: AttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: URL, spaceId: String) throws -> ChatLinkedObject {
        let gotAccess = input.startAccessingSecurityScopedResource()
        guard gotAccess else { throw AttachmentError.invalidFile }
        
        defer { input.stopAccessingSecurityScopedResource() }
        
        guard let fileData = try? fileActionsService.createFileData(fileUrl: input) else {
            throw AttachmentError.fileCreationFailed
        }
        
        return .localBinaryFile(ChatLocalBinaryFile(data: fileData))
    }
}

@MainActor
final class CameraMediaProcessor: AttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: ImagePickerMediaType, spaceId: String) throws -> ChatLinkedObject {
        switch input {
        case .image(let image, let type):
            guard let fileData = try? fileActionsService.createFileData(image: image, type: type) else {
                throw AttachmentError.fileCreationFailed
            }
            return .localBinaryFile(ChatLocalBinaryFile(data: fileData))
        case .video(let file):
            guard let fileData = try? fileActionsService.createFileData(fileUrl: file) else {
                throw AttachmentError.fileCreationFailed
            }
            return .localBinaryFile(ChatLocalBinaryFile(data: fileData))
        }
    }
}

@MainActor
final class PhotosPickerProcessor: AsyncAttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: PhotosPickerItem, spaceId: String) async throws -> ChatLinkedObject {
        let data = try await fileActionsService.createFileData(photoItem: input)
        return .localPhotosFile(ChatLocalPhotosFile(data: ChatLocalBinaryFile(data: data), photosPickerItemHash: input.hashValue))
    }
}

@MainActor
final class PasteBufferProcessor: AsyncAttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: NSItemProvider, spaceId: String) async throws -> ChatLinkedObject {
        guard let fileData = try? await fileActionsService.createFileData(source: .itemProvider(input)) else {
            throw AttachmentError.fileCreationFailed
        }
        return .localBinaryFile(ChatLocalBinaryFile(data: fileData))
    }
}

@MainActor
final class LinkPreviewProcessor: AsyncAttachmentProcessor {
    
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    
    func process(_ input: URL, spaceId: String) async throws -> ChatLinkedObject {
        let linkPreview = try await bookmarkService.fetchLinkPreview(url: AnytypeURL(url: input))
        let bookmark = ChatLocalBookmark(
            url: linkPreview.url,
            title: linkPreview.title,
            description: linkPreview.description_p,
            icon: URL(string: linkPreview.faviconURL).map { .url($0) } ?? .object(.emptyBookmarkIcon),
            loading: false
        )
        return .localBookmark(bookmark)
    }
}

@MainActor
final class UploadedObjectProcessor: AttachmentProcessor {
    
    func process(_ input: MessageAttachmentDetails, spaceId: String) throws -> ChatLinkedObject {
        return .uploadedObject(input)
    }
}
