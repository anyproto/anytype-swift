import Foundation
import Combine
import BlocksModels

final class DocumentViewModel: DocumentViewModelProtocol {
    
    // MARK: - Internal properties
    
    var documentId: String? {
        document.documentId
    }
    
    var rootActiveModel: BaseDocument.ActiveModel? {
        document.getRootActiveModel()
    }
    
    var userSession: BaseDocument.UserSession? {
        document.getUserSession()
    }
    
    var defaultDetailsActiveModel: DetailsActiveModel {
        document.getDefaultDetailsActiveModel()
    }
    
    // MARK: - Private properties
    
    private let document = BaseDocument()
    
    private let blocksConverter: CompoundViewModelConverter
    
    // MARK: - Initializer
    
    init() {
        self.blocksConverter = CompoundViewModelConverter(self.document)
    }

    // MARK: - Internal functions
    
    func open(_ value: ServiceSuccess) {
        document.open(value)
    }
    
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never> {
        document.modelsAndUpdatesPublisher()
            .receiveOnMain()
            .map { [weak self] (value) in
            DocumentViewModelUpdateResult(
                updates: value.updates,
                models: self?.blocksConverter.convert(value.models) ?? []
            )
        }.eraseToAnyPublisher()
    }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsEntryValueProvider, Never> {
        document.getDefaultPageDetailsPublisher()
    }
    
    func handle(events: BaseDocument.Events) {
        document.handle(events: events)
    }
    
}
