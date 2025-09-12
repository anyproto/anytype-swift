import Foundation
import Combine
import Services

@MainActor
final class ChatAttachmentState {
    
    nonisolated init() { }
    
    private let linkedObjectsSubject = CurrentValueSubject<[ChatLinkedObject], Never>([])
    private let attachmentsDownloadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let photosItemsTaskSubject = CurrentValueSubject<UUID, Never>(UUID())
    private var linkPreviewTasks: [URL: AnyCancellable] = [:]
    
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
    
    func addLinkedObject(_ object: ChatLinkedObject) {
        var current = linkedObjectsSubject.value
        current.append(object)
        linkedObjectsSubject.send(current)
    }
    
    func removeLinkedObject(with id: Int) {
        var current = linkedObjectsSubject.value
        current.removeAll { $0.id == id }
        linkedObjectsSubject.send(current)
    }
    
    func updateLinkedObject(at index: Int, with object: ChatLinkedObject) {
        var current = linkedObjectsSubject.value
        guard index < current.count else { return }
        current[index] = object
        linkedObjectsSubject.send(current)
    }
    
    func clearAllLinkedObjects() {
        linkedObjectsSubject.send([])
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
    
    func cancelAllLinkPreviewTasks() {
        linkPreviewTasks.values.forEach { $0.cancel() }
        linkPreviewTasks.removeAll()
    }
    
    func hasLinkPreviewTask(for url: URL) -> Bool {
        return linkPreviewTasks[url] != nil
    }
}
