import Foundation
import Services
import SwiftUI
import PhotosUI
import AnytypeCore
import UIKit
import Factory
@preconcurrency import Combine

protocol ChatAttachmentHandlerProtocol: ObservableObject {
    var linkedObjectsPublisher: AnyPublisher<[ChatLinkedObject], Never> { get }
    var attachmentsDownloadingPublisher: AnyPublisher<Bool, Never> { get }
    var photosItemsTaskPublisher: AnyPublisher<UUID, Never> { get }
    
    var showFileLimitAlert: (() -> Void)? { get set }
    
    func addUploadedObject(_ details: MessageAttachmentDetails)
    func removeLinkedObject(_ linkedObject: ChatLinkedObject)
    func clearAll()
    func canAddOneAttachment() -> Bool
    func setPhotosItems(_ items: [PhotosPickerItem])
    func handleFilePicker(result: Result<[URL], any Error>)
    func handleCameraMedia(_ media: ImagePickerMediaType)
    func handlePasteAttachmentsFromBuffer(items: [NSItemProvider]) async
    func updatePickerItems() async
    func handleLinkAdded(link: URL)
    func setLinkedObjects(_ objects: [ChatLinkedObject])
}

@MainActor
final class ChatAttachmentHandler: ChatAttachmentHandlerProtocol {
    
    // MARK: - Publishers
    
    private let linkedObjectsSubject = CurrentValueSubject<[ChatLinkedObject], Never>([])
    private let attachmentsDownloadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let photosItemsTaskSubject = CurrentValueSubject<UUID, Never>(UUID())
    
    var linkedObjectsPublisher: AnyPublisher<[ChatLinkedObject], Never> {
        linkedObjectsSubject.eraseToAnyPublisher()
    }
    
    var attachmentsDownloadingPublisher: AnyPublisher<Bool, Never> {
        attachmentsDownloadingSubject.eraseToAnyPublisher()
    }
    
    var photosItemsTaskPublisher: AnyPublisher<UUID, Never> {
        photosItemsTaskSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private State
    
    private var photosItems: [PhotosPickerItem] = []
    private var linkPreviewTasks: [URL: AnyCancellable] = [:]
    
    // MARK: - Dependencies
    
    private let spaceId: String
    
    @Injected(\.chatMessageLimits)
    private var chatMessageLimits: any ChatMessageLimitsProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    
    // MARK: - Callbacks
    
    var showFileLimitAlert: (() -> Void)?
    
    // MARK: - Init
    
    nonisolated init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    // MARK: - Public Methods
    
    func addUploadedObject(_ details: MessageAttachmentDetails) {
        if chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjectsSubject.value.count) {
            var currentObjects = linkedObjectsSubject.value
            currentObjects.append(.uploadedObject(details))
            linkedObjectsSubject.send(currentObjects)
            AnytypeAnalytics.instance().logAttachItemChat(type: .object)
        } else {
            showFileLimitAlert?()
        }
    }
    
    func removeLinkedObject(_ linkedObject: ChatLinkedObject) {
        withAnimation {
            var currentObjects = linkedObjectsSubject.value
            currentObjects.removeAll { $0.id == linkedObject.id }
            linkedObjectsSubject.send(currentObjects)
            photosItems.removeAll { $0.hashValue == linkedObject.id }
        }
        AnytypeAnalytics.instance().logDetachItemChat()
    }
    
    func clearAll() {
        linkedObjectsSubject.send([])
        photosItems = []
        photosItemsTaskSubject.send(UUID())
        linkPreviewTasks.values.forEach { $0.cancel() }
        linkPreviewTasks.removeAll()
    }
    
    func canAddOneAttachment() -> Bool {
        return chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjectsSubject.value.count)
    }
    
    func setPhotosItems(_ items: [PhotosPickerItem]) {
        photosItems = items
        photosItemsTaskSubject.send(UUID())
    }
    
    func setLinkedObjects(_ objects: [ChatLinkedObject]) {
        linkedObjectsSubject.send(objects)
    }
    
    // MARK: - File Operations
    
    func handleFilePicker(result: Result<[URL], any Error>) {
        switch result {
        case .success(let files):
            for file in files {
                if !chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjectsSubject.value.count) {
                    showFileLimitAlert?()
                    return
                }
                let gotAccess = file.startAccessingSecurityScopedResource()
                guard gotAccess else { return }
                
                if let fileData = try? fileActionsService.createFileData(fileUrl: file) {
                    var currentObjects = linkedObjectsSubject.value
                    currentObjects.append(.localBinaryFile(fileData))
                    linkedObjectsSubject.send(currentObjects)
                }
                
                file.stopAccessingSecurityScopedResource()
            }
            AnytypeAnalytics.instance().logAttachItemChat(type: .file)
        case .failure:
            break
        }
    }
    
    func handleCameraMedia(_ media: ImagePickerMediaType) {
        if !chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjectsSubject.value.count) {
            showFileLimitAlert?()
            return
        }
        switch media {
        case .image(let image, let type):
            if let fileData = try? fileActionsService.createFileData(image: image, type: type) {
                var currentObjects = linkedObjectsSubject.value
                currentObjects.append(.localBinaryFile(fileData))
                linkedObjectsSubject.send(currentObjects)
            }
        case .video(let file):
            if let fileData = try? fileActionsService.createFileData(fileUrl: file) {
                var currentObjects = linkedObjectsSubject.value
                currentObjects.append(.localBinaryFile(fileData))
                linkedObjectsSubject.send(currentObjects)
            }
        }
        AnytypeAnalytics.instance().logAttachItemChat(type: .camera)
    }
    
    func handlePasteAttachmentsFromBuffer(items: [NSItemProvider]) async {
        for item in items {
            if !chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjectsSubject.value.count) {
                showFileLimitAlert?()
                return
            }
            
            if let fileData = try? await fileActionsService.createFileData(source: .itemProvider(item)) {
                var currentObjects = linkedObjectsSubject.value
                currentObjects.append(.localBinaryFile(fileData))
                linkedObjectsSubject.send(currentObjects)
                AnytypeAnalytics.instance().logAttachItemChat(type: .file)
            }
        }
    }
    
    // MARK: - Photos Picker
    
    func updatePickerItems() async {
        attachmentsDownloadingSubject.send(true)
        defer { attachmentsDownloadingSubject.send(false) }
        
        let newItemsIds = Set(photosItems.map(\.hashValue))
        let linkedIds = Set(linkedObjectsSubject.value.compactMap(\.localPhotosFile?.photosPickerItemHash))
        let removeIds = linkedIds.subtracting(newItemsIds)
        let addIds = newItemsIds.subtracting(linkedIds)
        
        // Remove old
        var currentObjects = linkedObjectsSubject.value
        currentObjects.removeAll { removeIds.contains($0.id) }
        linkedObjectsSubject.send(currentObjects)
        var newItems = photosItems.filter { addIds.contains($0.hashValue) }
        
        // Remove over limit
        let availableItemsCount = chatMessageLimits.countAttachmentsCanBeAdded(current: linkedObjectsSubject.value.count)
        if availableItemsCount < newItems.count {
            let deletedIds = newItems[availableItemsCount..<newItems.count]
            newItems.removeLast(newItems.count - availableItemsCount)
            photosItems.removeAll { deletedIds.contains($0) }
            showFileLimitAlert?()
        }
        
        // Add new in loading state
        let newLinkedObjects = newItems.map {
            ChatLinkedObject.localPhotosFile(
                ChatLocalPhotosFile(data: nil, photosPickerItemHash: $0.hashValue)
            )
        }
        currentObjects = linkedObjectsSubject.value
        currentObjects.append(contentsOf: newLinkedObjects)
        linkedObjectsSubject.send(currentObjects)
        
        for photosItem in newItems {
            do {
                let data = try await fileActionsService.createFileData(photoItem: photosItem)
                let linkeObject = ChatLinkedObject.localPhotosFile(
                    ChatLocalPhotosFile(data: data, photosPickerItemHash: photosItem.hashValue)
                )
                currentObjects = linkedObjectsSubject.value
                if let index = currentObjects.firstIndex(where: { $0.id == photosItem.hashValue }) {
                    currentObjects[index] = linkeObject
                    linkedObjectsSubject.send(currentObjects)
                } else {
                    currentObjects.append(linkeObject)
                    linkedObjectsSubject.send(currentObjects)
                    anytypeAssertionFailure("Linked object should be added in loading state")
                }
            } catch {
                currentObjects = linkedObjectsSubject.value
                currentObjects.removeAll { $0.id == photosItem.hashValue }
                linkedObjectsSubject.send(currentObjects)
                photosItems.removeAll { $0 == photosItem }
            }
        }
        
        if newItems.isNotEmpty {
            AnytypeAnalytics.instance().logAttachItemChat(type: .photo)
        }
    }
    
    // MARK: - Link Preview
    
    func handleLinkAdded(link: URL) {
        guard link.containsHttpProtocol else { return }
        let contains = linkedObjectsSubject.value.contains { $0.localBookmark?.url == link.absoluteString }
        guard !contains else { return }
        var currentObjects = linkedObjectsSubject.value
        currentObjects.append(.localBookmark(ChatLocalBookmark.placeholder(url: link)))
        linkedObjectsSubject.send(currentObjects)
        let task = Task { [bookmarkService, weak self] in
            do {
                let linkPreview = try await bookmarkService.fetchLinkPreview(url: AnytypeURL(url: link))
                self?.updateLocalBookmark(linkPreview: linkPreview)
            } catch {
                guard let self = self else { return }
                var currentObjects = self.linkedObjectsSubject.value
                currentObjects.removeAll { $0.localBookmark?.url == link.absoluteString }
                self.linkedObjectsSubject.send(currentObjects)
            }
            self?.linkPreviewTasks[link] = nil
            AnytypeAnalytics.instance().logAttachItemChat(type: .object)
        }
        linkPreviewTasks[link] = task.cancellable()
    }
    
    // MARK: - Private Methods
    
    private func updateLocalBookmark(linkPreview: LinkPreview) {
        var currentObjects = linkedObjectsSubject.value
        guard let index = currentObjects.firstIndex(where: { $0.localBookmark?.url == linkPreview.url }) else { return }
        let bookmark = ChatLocalBookmark(
            url: linkPreview.url,
            title: linkPreview.title,
            description: linkPreview.description_p,
            icon: URL(string: linkPreview.faviconURL).map { .url($0) } ?? .object(.emptyBookmarkIcon), 
            loading: false
        )
        currentObjects[index] = .localBookmark(bookmark)
        linkedObjectsSubject.send(currentObjects)
    }
}
