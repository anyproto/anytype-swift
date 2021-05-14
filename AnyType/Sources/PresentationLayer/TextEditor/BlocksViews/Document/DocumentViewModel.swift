import Foundation
import Combine
import BlocksModels
import os


final class DocumentViewModel: DocumentViewModelProtocol {
    var documentId: String? { self.document.documentId }
    var rootActiveModel: BaseDocument.ActiveModel? { self.document.getRootActiveModel() }
    var userSession: BaseDocument.UserSession? { self.document.getUserSession() }
    
    var defaultActiveDetails: DetailsActiveModel {
        self.document.getDefaultDetails()
    }
    
    private let blocksConverter: CompoundViewModelConverter
    private let detailsConverter: DetailsViewModelConverter
    private let document = BaseDocument()
    
    init() {
        self.blocksConverter = CompoundViewModelConverter(self.document)
        self.detailsConverter = DetailsViewModelConverter(self.document)
    }

    // MARK: - Public
    func open(_ value: ServiceSuccess) {
        self.document.open(value)
    }
    
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never> {
        self.document.modelsAndUpdatesPublisher()
            .reciveOnMain()
            .map { [weak self] (value) in
            DocumentViewModelUpdateResult(
                updates: value.updates,
                models: self?.blocksConverter.convert(value.models) ?? []
            )
        }.eraseToAnyPublisher()
    }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsInformationProvider, Never> {
        self.document.getDefaultPageDetailsPublisher()
    }
    
    func handle(events: BaseDocument.Events) {
        self.document.handle(events: events)
    }
}
