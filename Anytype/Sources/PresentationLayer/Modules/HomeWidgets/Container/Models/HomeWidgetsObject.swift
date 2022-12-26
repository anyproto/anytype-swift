import Foundation
import BlocksModels
import Combine

protocol HomeWidgetsObjectProtocol: AnyObject {
    
    var objectId: String { get }
    var widgetsPublisher: AnyPublisher<[BlockInformation], Never> { get }
    var infoContainer: InfoContainerProtocol { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func close() async throws
    
    func targetObjectIdByLinkFor(widgetBlockId: BlockId) -> String?
}

final class HomeWidgetsObject: HomeWidgetsObjectProtocol {
    
    // MARK: - Private properties
    private var subscriptions = [AnyCancellable]()
    private let baseDocument: BaseDocumentProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    
    init(objectId: String, objectDetailsStorage: ObjectDetailsStorage) {
        self.baseDocument = BaseDocument(objectId: objectId)
        self.objectDetailsStorage = objectDetailsStorage
        setupSubscriptions()
    }
    
    // MARK: - HomeWidgetsObjectProtocol
    
    var objectId: String {
        return baseDocument.objectId
    }
    
    private var widgetsSubject = CurrentValueSubject<[BlockInformation], Never>([])
    var widgetsPublisher: AnyPublisher<[BlockInformation], Never> {
        widgetsSubject.eraseToAnyPublisher()
    }
    
    var infoContainer: InfoContainerProtocol {
        return baseDocument.infoContainer
    }
    
    @MainActor
    func open() async throws {
        try await baseDocument.open()
    }
    
    @MainActor
    func close() async throws {
        try await baseDocument.close()
    }
    
    func targetObjectIdByLinkFor(widgetBlockId: BlockId) -> String? {
        guard let block = infoContainer.get(id: widgetBlockId),
              let contentId = block.childrenIds.first,
              let contentInfo = infoContainer.get(id: contentId),
              case let .link(link) = contentInfo.content else { return nil }
        
        return link.targetBlockID
    }
    
    // MARK: - Private
    
    private func setupSubscriptions() {
        baseDocument.updatePublisher
            .map { [weak self] _ in
                guard let self = self else { return [] }
                return self.baseDocument.children.filter(\.isWidget)
            }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] in self?.widgetsSubject.send($0) }
            .store(in: &subscriptions)
    }
}
