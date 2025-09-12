import Foundation
import Services
import SwiftUI
import PhotosUI
import AnytypeCore
import UIKit
import Factory
@preconcurrency import Combine

@MainActor
protocol ChatAttachmentHandlerProtocol: ObservableObject {
    var linkedObjectsPublisher: AnyPublisher<[ChatLinkedObject], Never> { get }
    var attachmentsDownloadingPublisher: AnyPublisher<Bool, Never> { get }
    var photosItemsTaskPublisher: AnyPublisher<UUID, Never> { get }
    
    func addUploadedObject(_ details: MessageAttachmentDetails) throws
    func removeLinkedObject(_ linkedObject: ChatLinkedObject)
    func clearAll()
    func canAddOneAttachment() -> Bool
    func setPhotosItems(_ items: [PhotosPickerItem]) throws
    func handleFilePicker(result: Result<[URL], any Error>) throws
    func handleCameraMedia(_ media: ImagePickerMediaType) throws
    func handlePasteAttachmentsFromBuffer(items: [NSItemProvider]) async throws
    func updatePickerItems() async throws
    func handleLinkAdded(link: URL)
    func setLinkedObjects(_ objects: [ChatLinkedObject])
}

private struct ProcessedPhotosItems {
    let newItems: [PhotosPickerItem]
    let removedIds: Set<Int>
}

enum AttachmentError: Error {
    case fileLimitExceeded
    case fileCreationFailed
    case invalidFile
}

@MainActor
final class ChatAttachmentHandler: ChatAttachmentHandlerProtocol {
    
    // MARK: - State
    
    private let state = ChatAttachmentState()
    
    var linkedObjectsPublisher: AnyPublisher<[ChatLinkedObject], Never> {
        state.linkedObjectsPublisher
    }
    
    var attachmentsDownloadingPublisher: AnyPublisher<Bool, Never> {
        state.attachmentsDownloadingPublisher
    }
    
    var photosItemsTaskPublisher: AnyPublisher<UUID, Never> {
        state.photosItemsTaskPublisher
    }
    
    // MARK: - Private State
    
    // MARK: - Dependencies
    
    private let spaceId: String
    
    @Injected(\.chatAttachmentValidator)
    private var validator: ChatAttachmentValidator
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    
    
    // MARK: - Init
    
    nonisolated init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    // MARK: - Public Methods
    
    func addUploadedObject(_ details: MessageAttachmentDetails) throws {
        let validation = validator.validateSingleAttachment(currentCount: state.linkedObjects.count)
        guard validation.canAdd else {
            throw AttachmentError.fileLimitExceeded
        }
        state.addLinkedObject(.uploadedObject(details))
        AnytypeAnalytics.instance().logAttachItemChat(type: .object)
    }
    
    func removeLinkedObject(_ linkedObject: ChatLinkedObject) {
        state.removeLinkedObject(with: linkedObject.id)
        state.removePhotosItems { $0.hashValue == linkedObject.id }
        AnytypeAnalytics.instance().logDetachItemChat()
    }
    
    func clearAll() {
        state.clearAllLinkedObjects()
        state.clearPhotosItems()
        state.updatePhotosItemsTask()
        state.cancelAllLinkPreviewTasks()
    }
    
    func canAddOneAttachment() -> Bool {
        return validator.validateSingleAttachment(currentCount: state.linkedObjects.count).canAdd
    }
    
    func setPhotosItems(_ items: [PhotosPickerItem]) throws {
        state.setPhotosItems(items)
        state.updatePhotosItemsTask()
    }
    
    func setLinkedObjects(_ objects: [ChatLinkedObject]) {
        state.setLinkedObjects(objects)
    }
    
    // MARK: - File Operations
    
    func handleFilePicker(result: Result<[URL], any Error>) throws {
        switch result {
        case .success(let files):
            for file in files {
                let validation = validator.validateSingleAttachment(currentCount: state.linkedObjects.count)
                guard validation.canAdd else {
                    throw AttachmentError.fileLimitExceeded
                }
                let gotAccess = file.startAccessingSecurityScopedResource()
                guard gotAccess else { throw AttachmentError.invalidFile }
                
                guard let fileData = try? fileActionsService.createFileData(fileUrl: file) else {
                    file.stopAccessingSecurityScopedResource()
                    throw AttachmentError.fileCreationFailed
                }
                state.addLinkedObject(.localBinaryFile(fileData))
                file.stopAccessingSecurityScopedResource()
            }
            AnytypeAnalytics.instance().logAttachItemChat(type: .file)
        case .failure:
            throw AttachmentError.invalidFile
        }
    }
    
    func handleCameraMedia(_ media: ImagePickerMediaType) throws {
        let validation = validator.validateSingleAttachment(currentCount: state.linkedObjects.count)
        guard validation.canAdd else {
            throw AttachmentError.fileLimitExceeded
        }
        switch media {
        case .image(let image, let type):
            guard let fileData = try? fileActionsService.createFileData(image: image, type: type) else {
                throw AttachmentError.fileCreationFailed
            }
            state.addLinkedObject(.localBinaryFile(fileData))
        case .video(let file):
            guard let fileData = try? fileActionsService.createFileData(fileUrl: file) else {
                throw AttachmentError.fileCreationFailed
            }
            state.addLinkedObject(.localBinaryFile(fileData))
        }
        AnytypeAnalytics.instance().logAttachItemChat(type: .camera)
    }
    
    func handlePasteAttachmentsFromBuffer(items: [NSItemProvider]) async throws {
        for item in items {
            let validation = validator.validateSingleAttachment(currentCount: state.linkedObjects.count)
            guard validation.canAdd else {
                throw AttachmentError.fileLimitExceeded
            }
            
            guard let fileData = try? await fileActionsService.createFileData(source: .itemProvider(item)) else {
                throw AttachmentError.fileCreationFailed
            }
            state.addLinkedObject(.localBinaryFile(fileData))
            AnytypeAnalytics.instance().logAttachItemChat(type: .file)
        }
    }
    
    // MARK: - Photos Picker
    
    func updatePickerItems() async throws {
        state.setAttachmentsDownloading(true)
        defer { state.setAttachmentsDownloading(false) }
        
        let processedItems = processPhotosPickerItems()
        var newItems = processedItems.newItems
        let limitExceeded = enforceAttachmentLimits(on: &newItems)
        
        if !newItems.isEmpty {
            await addPhotosInLoadingState(newItems)
            await processPhotosData(newItems)
            AnytypeAnalytics.instance().logAttachItemChat(type: .photo)
        }
        
        if limitExceeded {
            throw AttachmentError.fileLimitExceeded
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func processPhotosPickerItems() -> ProcessedPhotosItems {
        let photosItems = state.getPhotosItems()
        let newItemsIds = Set(photosItems.map(\.hashValue))
        let linkedIds = Set(state.linkedObjects.compactMap(\.localPhotosFile?.photosPickerItemHash))
        let removeIds = linkedIds.subtracting(newItemsIds)
        let addIds = newItemsIds.subtracting(linkedIds)
        
        // Remove old items
        var currentObjects = state.linkedObjects
        currentObjects.removeAll { removeIds.contains($0.id) }
        state.setLinkedObjects(currentObjects)
        
        let newItems = photosItems.filter { addIds.contains($0.hashValue) }
        return ProcessedPhotosItems(newItems: newItems, removedIds: removeIds)
    }
    
    private func enforceAttachmentLimits(on newItems: inout [PhotosPickerItem]) -> Bool {
        let validation = validator.validateMultipleAttachments(currentCount: state.linkedObjects.count, addingCount: newItems.count)
        
        guard !validation.canAdd else { return false }
        
        let deletedIds = newItems[validation.remainingCount..<newItems.count]
        newItems.removeLast(newItems.count - validation.remainingCount)
        state.removePhotosItems { deletedIds.contains($0) }
        return true
    }
    
    private func addPhotosInLoadingState(_ items: [PhotosPickerItem]) async {
        let newLinkedObjects = items.map {
            ChatLinkedObject.localPhotosFile(
                ChatLocalPhotosFile(data: nil, photosPickerItemHash: $0.hashValue)
            )
        }
        var currentObjects = state.linkedObjects
        currentObjects.append(contentsOf: newLinkedObjects)
        state.setLinkedObjects(currentObjects)
    }
    
    private func processPhotosData(_ items: [PhotosPickerItem]) async {
        for photosItem in items {
            do {
                let data = try await fileActionsService.createFileData(photoItem: photosItem)
                let linkedObject = ChatLinkedObject.localPhotosFile(
                    ChatLocalPhotosFile(data: data, photosPickerItemHash: photosItem.hashValue)
                )
                let currentObjects = state.linkedObjects
                if let index = currentObjects.firstIndex(where: { $0.id == photosItem.hashValue }) {
                    state.updateLinkedObject(at: index, with: linkedObject)
                } else {
                    state.addLinkedObject(linkedObject)
                    anytypeAssertionFailure("Linked object should be added in loading state")
                }
            } catch {
                state.removeLinkedObject(with: photosItem.hashValue)
                state.removePhotosItems { $0 == photosItem }
            }
        }
    }
    
    // MARK: - Link Preview
    
    func handleLinkAdded(link: URL) {
        guard link.containsHttpProtocol else { return }
        let contains = state.linkedObjects.contains { $0.localBookmark?.url == link.absoluteString }
        guard !contains else { return }
        state.addLinkedObject(.localBookmark(ChatLocalBookmark.placeholder(url: link)))
        let task = Task { [bookmarkService, weak self] in
            do {
                let linkPreview = try await bookmarkService.fetchLinkPreview(url: AnytypeURL(url: link))
                self?.updateLocalBookmark(linkPreview: linkPreview)
            } catch {
                guard let self = self else { return }
                var currentObjects = self.state.linkedObjects
                currentObjects.removeAll { $0.localBookmark?.url == link.absoluteString }
                self.state.setLinkedObjects(currentObjects)
            }
            self?.state.removeLinkPreviewTask(for: link)
            AnytypeAnalytics.instance().logAttachItemChat(type: .object)
        }
        state.addLinkPreviewTask(for: link, task: task.cancellable())
    }
    
    // MARK: - Private Methods
    
    private func updateLocalBookmark(linkPreview: LinkPreview) {
        guard let index = state.linkedObjects.firstIndex(where: { $0.localBookmark?.url == linkPreview.url }) else { return }
        let bookmark = ChatLocalBookmark(
            url: linkPreview.url,
            title: linkPreview.title,
            description: linkPreview.description_p,
            icon: URL(string: linkPreview.faviconURL).map { .url($0) } ?? .object(.emptyBookmarkIcon), 
            loading: false
        )
        state.updateLinkedObject(at: index, with: .localBookmark(bookmark))
    }
}
