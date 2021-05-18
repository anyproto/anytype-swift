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
    
    private let blocksConverter: CompoundViewModelConverter
    private let detailsConverter: DetailsViewModelConverter
    private let document = BaseDocument()
    
    // MARK: - Initializer
    
    init() {
        self.blocksConverter = CompoundViewModelConverter(self.document)
        self.detailsConverter = DetailsViewModelConverter(self.document)
    }

    // MARK: - Internal functions
    
    func open(_ value: ServiceSuccess) {
        document.open(value)
    }
    
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never> {
        document.modelsAndUpdatesPublisher()
            .reciveOnMain()
            .map { [weak self] (value) in
            DocumentViewModelUpdateResult(
                updates: value.updates,
                models: self?.blocksConverter.convert(value.models) ?? []
            )
        }.eraseToAnyPublisher()
    }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsInformationProvider, Never> {
        document.getDefaultPageDetailsPublisher()
    }
    
    func handle(events: BaseDocument.Events) {
        document.handle(events: events)
    }
    
}
