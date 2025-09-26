import Foundation
import Combine
import Services
import PhotosUI
import _PhotosUI_SwiftUI


@MainActor
final class ChatAttachmentState {

    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    private let linkedObjectsSubject = CurrentValueSubject<[ChatLinkedObject], Never>([])
    private let attachmentsDownloadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let photosItemsTaskSubject = CurrentValueSubject<UUID, Never>(UUID())
    private var linkPreviewTasks: [URL: AnyCancellable] = [:]
    private var preloadTasks: [Int: Task<Void, Never>] = [:]
    private var photosItems: [PhotosPickerItem] = []
    
    let spaceId: String
    
    nonisolated init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    var linkedObjectsPublisher: AnyPublisher<[ChatLinkedObject], Never> {
        linkedObjectsSubject.eraseToAnyPublisher()
    }
    
    var attachmentsDownloadingPublisher: AnyPublisher<Bool, Never> {
        attachmentsDownloadingSubject.eraseToAnyPublisher()
    }
    
    var photosItemsTaskPublisher: AnyPublisher<UUID, Never> {
        photosItemsTaskSubject.eraseToAnyPublisher()
    }
    
    var linkedObjects: [ChatLinkedObject] {
        linkedObjectsSubject.value
    }
    
    func setLinkedObjects(_ objects: [ChatLinkedObject]) {
        linkedObjectsSubject.send(objects)
    }
    
    func setAttachmentsDownloading(_ downloading: Bool) {
        attachmentsDownloadingSubject.send(downloading)
    }
    
    func updatePhotosItemsTask() {
        photosItemsTaskSubject.send(UUID())
    }
    
    func addLinkPreviewTask(for url: URL, task: AnyCancellable) {
        linkPreviewTasks[url] = task
    }
    
    func removeLinkPreviewTask(for url: URL) {
        linkPreviewTasks[url] = nil
    }
    
    func hasLinkPreviewTask(for url: URL) -> Bool {
        return linkPreviewTasks[url] != nil
    }
    
    func setPhotosItems(_ items: [PhotosPickerItem]) {
        photosItems = items
    }
    
    func getPhotosItems() -> [PhotosPickerItem] {
        return photosItems
    }
    
    func removePhotosItems(where predicate: (PhotosPickerItem) -> Bool) {
        photosItems.removeAll(where: predicate)
    }
    
    func clearState() {
        preloadTasks.values.forEach { $0.cancel() }
        preloadTasks.removeAll()
        
        discardPreloadedFiles(linkedObjects.compactMap { $0.preloadFileId })
        
        linkedObjectsSubject.send([])
        
        linkPreviewTasks.values.forEach { $0.cancel() }
        linkPreviewTasks.removeAll()
        
        photosItems = []
        
        updatePhotosItemsTask()
    }

    func addLinkedObject(_ linkedObject: ChatLinkedObject) {
        storeLinkedObject(linkedObject)
        startPreload(linkedObject: linkedObject)
    }
    
    private func storeLinkedObject(_ object: ChatLinkedObject) {
        var current = linkedObjectsSubject.value
        current.append(object)
        linkedObjectsSubject.send(current)
    }

    func updateLinkedObject(at index: Int, with linkedObject: ChatLinkedObject) {
        updateLinkedObjectStorage(at: index, with: linkedObject)
        startPreload(linkedObject: linkedObject)
    }
    
    private func updateLinkedObjectStorage(at index: Int, with object: ChatLinkedObject) {
        var current = linkedObjectsSubject.value
        guard index < current.count else { return }
        current[index] = object
        linkedObjectsSubject.send(current)
    }

    func removeLinkedObject(with id: Int) {
        if let objectToRemove = linkedObjects.first(where: { $0.id == id }) {
            discardPreloadedFile(from: objectToRemove)
        }
        removeLinkedObjectFromStorage(with: id)
    }
    
    private func removeLinkedObjectFromStorage(with id: Int) {
        var current = linkedObjectsSubject.value
        current.removeAll { $0.id == id }
        linkedObjectsSubject.send(current)
    }

    private func startPreload(linkedObject: ChatLinkedObject) {
        guard let data = linkedObject.fileData else { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            if let preloadFileId = try? await fileActionsService.preloadFileObject(spaceId: spaceId, data: data, origin: .none) {
                await MainActor.run { self.updatePreloadFileId(for: linkedObject.id, preloadFileId: preloadFileId) }
            }
            await MainActor.run { self.removePreloadTask(objectId: linkedObject.id) }
        }

        addPreloadTask(objectId: linkedObject.id, task: task)
    }
    
    private func updatePreloadFileId(for objectId: Int, preloadFileId: String) {
        var linkedObjects = linkedObjectsSubject.value
        guard let index = linkedObjects.firstIndex(where: { $0.id == objectId }) else { return }

        switch linkedObjects[index] {
        case .localPhotosFile(var file):
            file.data?.preloadFileId = preloadFileId
            linkedObjects[index] = .localPhotosFile(file)
        case .localBinaryFile(var file):
            file.preloadFileId = preloadFileId
            linkedObjects[index] = .localBinaryFile(file)
        default:
            return
        }

        linkedObjectsSubject.send(linkedObjects)
    }
    
    private func addPreloadTask(objectId: Int, task: Task<Void, Never>) {
        removePreloadTask(objectId: objectId)
        preloadTasks[objectId] = task
    }
    
    private func removePreloadTask(objectId: Int) {
        preloadTasks[objectId]?.cancel()
        preloadTasks[objectId] = nil
    }

    private func discardPreloadedFile(from linkedObject: ChatLinkedObject) {
        guard let preloadFileId = linkedObject.preloadFileId else { return }
        discardPreloadedFiles([preloadFileId])
    }

    private func discardPreloadedFiles(_ preloadFileIds: [String]) {
        for preloadFileId in preloadFileIds {
            Task {
                try await fileActionsService.discardPreloadFile(fileId: preloadFileId, spaceId: spaceId)
            }
        }
    }
}
