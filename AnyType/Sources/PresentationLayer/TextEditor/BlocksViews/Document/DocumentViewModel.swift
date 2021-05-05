import Foundation
import Combine
import BlocksModels
import os


final class DocumentViewModel: DocumentViewModelProtocol {
    var documentId: String? { self.document.documentId }
    var rootActiveModel: BaseDocument.ActiveModel? { self.document.getRootActiveModel() }
    var userSession: BaseDocument.UserSession? { self.document.getUserSession() }
    
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
    
    func detailsViewModels() -> [BaseBlockViewModel] {
        detailsViewModels(orderedBy: DocumentViewModelPredicate())
    }
    
    func detailsViewModels(orderedBy predicate: DocumentViewModelPredicate) -> [BaseBlockViewModel] {
        predicate.list.compactMap({ value -> BaseBlockViewModel? in
            guard let model = self.document.getDefaultDetailsActiveModel(of: value) else { return nil }
            guard let viewModel = self.detailsConverter.convert(model, kind: value) else { return nil }
            return viewModel.configured(pageDetailsViewModel: document.getDefaultDetails())
        })
    }
    
    func handle(events: BaseDocument.Events) {
        self.document.handle(events: events)
    }
}
