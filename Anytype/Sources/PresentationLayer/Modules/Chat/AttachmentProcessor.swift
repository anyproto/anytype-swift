import Foundation
import Services
import PhotosUI
import UIKit
import Factory
import AnytypeCore

protocol AttachmentProcessor {
    associatedtype Input
    func process(_ input: Input, spaceId: String) throws -> ChatLinkedObject
}

protocol AsyncAttachmentProcessor {
    associatedtype Input
    func process(_ input: Input, spaceId: String) async throws -> ChatLinkedObject
}

@MainActor
struct FileAttachmentProcessor: AttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: URL, spaceId: String) throws -> ChatLinkedObject {
        let gotAccess = input.startAccessingSecurityScopedResource()
        guard gotAccess else { throw AttachmentError.invalidFile }
        
        defer { input.stopAccessingSecurityScopedResource() }
        
        guard let fileData = try? fileActionsService.createFileData(fileUrl: input) else {
            throw AttachmentError.fileCreationFailed
        }
        
        return .localBinaryFile(fileData)
    }
}

@MainActor
struct CameraMediaProcessor: AttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: ImagePickerMediaType, spaceId: String) throws -> ChatLinkedObject {
        switch input {
        case .image(let image, let type):
            guard let fileData = try? fileActionsService.createFileData(image: image, type: type) else {
                throw AttachmentError.fileCreationFailed
            }
            return .localBinaryFile(fileData)
        case .video(let file):
            guard let fileData = try? fileActionsService.createFileData(fileUrl: file) else {
                throw AttachmentError.fileCreationFailed
            }
            return .localBinaryFile(fileData)
        }
    }
}

@MainActor
struct PhotosPickerProcessor: AsyncAttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: PhotosPickerItem, spaceId: String) async throws -> ChatLinkedObject {
        let data = try await fileActionsService.createFileData(photoItem: input)
        return .localPhotosFile(ChatLocalPhotosFile(data: data, photosPickerItemHash: input.hashValue))
    }
}

@MainActor
struct PasteBufferProcessor: AsyncAttachmentProcessor {
    
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    func process(_ input: NSItemProvider, spaceId: String) async throws -> ChatLinkedObject {
        guard let fileData = try? await fileActionsService.createFileData(source: .itemProvider(input)) else {
            throw AttachmentError.fileCreationFailed
        }
        return .localBinaryFile(fileData)
    }
}

@MainActor
struct LinkPreviewProcessor: AsyncAttachmentProcessor {
    
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
struct UploadedObjectProcessor: AttachmentProcessor {
    
    func process(_ input: MessageAttachmentDetails, spaceId: String) throws -> ChatLinkedObject {
        return .uploadedObject(input)
    }
}