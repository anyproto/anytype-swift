import Foundation
import BlocksModels
import Combine

protocol HomeWidgetsObjectProtocol: AnyObject {
    
    var widgetsPublisher: AnyPublisher<[BlockInformation], Never> { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func close() async throws
}

final class HomeWidgetsObject: HomeWidgetsObjectProtocol {
    
    // MARK: - Private properties
    private var subscriptions = [AnyCancellable]()
    private let baseDocument: BaseDocumentProtocol
    
    init(objectId: String) {
        self.baseDocument = BaseDocument(objectId: objectId)
        setupSubscriptions()
    }
    
    // MARK: - HomeWidgetsObjectProtocol
    
    private var widgetsSubject = CurrentValueSubject<[BlockInformation], Never>([])
    var widgetsPublisher: AnyPublisher<[BlockInformation], Never> {
        widgetsSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    func open() async throws {
        try await baseDocument.open()
    }
    
    @MainActor
    func close() async throws {
        try await baseDocument.close()
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
        
//        baseDocument.infoContainer.publisherFor(id: baseDocument.objectId)
//            .map { [weak self] info in
//                guard let info = info else { return [] }
//                return info.childrenIds
//                    .compactMap { self?.baseDocument.infoContainer.get(id: $0) }
//                    .filter(\.isWidget)
//            }
//            .sink { [weak self] in self?.widgetsSubject.send($0) }
//            .store(in: &subscriptions)
        
//        baseDocument.childrenPublisher
//            .map { $0.filter(\.isWidget) }
//            .removeDuplicates()
//            .receiveOnMain()
//            .sink { [weak self] in self?.widgetsSubject.send($0) }
//            .store(in: &subscriptions)
    }
}
