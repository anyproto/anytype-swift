import Foundation
import Combine
import BlocksModels
import os


final class DocumentViewModel {
    private var blocksConverter: CompoundViewModelConverter?
    private var detailsConverter: DetailsViewModelConverter
    private(set) var document: BaseDocument
    
    // TODO: Remove
    var documentId: String? { self.document.documentId }
    
    init(_ document: BaseDocument = BaseDocument()) {
        self.document = document
        self.blocksConverter = CompoundViewModelConverter(self.document)
        self.detailsConverter = DetailsViewModelConverter(self.document)
    }

    // MARK: - Open
    func open(_ documentId: BlockId) {
        _ = self.document.open(documentId).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(value):
                assertionFailure("open(_ documentId). Error has occurred. \(value)")
            }
        }, receiveValue: {})
    }
    func open(_ documentId: BlockId) -> AnyPublisher<Void, Error> {
        self.document.open(documentId)
    }
    func open(_ value: ServiceSuccess) {
        self.document.open(value)
    }

    // MARK: - ViewModels
    typealias BlockViewModel = BlocksViews.Base.ViewModel
    struct UpdateResult {
        var updates: BaseDocument.ModelsUpdates
        var models: [BlockViewModel]
    }
    
    private func viewModels(from models: [BaseDocument.ActiveModel]) -> [BlockViewModel] {
        self.blocksConverter?.convert(models) ?? []
    }
    
    func updatePublisher() -> AnyPublisher<UpdateResult, Never> {
        self.document.modelsAndUpdatesPublisher().map { [weak self] (value) in
            .init(updates: value.updates, models: self?.viewModels(from: value.models) ?? [])
        }.eraseToAnyPublisher()
    }

    // MARK: - Models
    func getRootActiveModel() -> BaseDocument.ActiveModel? {
        self.document.getRootActiveModel()
    }
    func getUserSession() -> BaseDocument.UserSession? {
        self.document.getUserSession()
    }

    // MARK: - Details
    struct Predicate {
        var list: [DetailsContent.Kind] = [.iconEmoji, .title]
    }
    
    func defaultDetails() -> DetailsActiveModel {
        self.document.getDefaultDetails()
    }
    
    func defaultPageDetails() -> DetailsInformationProvider {
        self.document.getDefaultPageDetails()
    }
    
    func defaultPageDetailsPublisher() -> AnyPublisher<DetailsInformationProvider, Never> {
        self.document.getDefaultPageDetailsPublisher()
    }
    
    func defaultDetailsViewModels(orderedBy predicate: Predicate = .init()) -> [BlockViewModel] {
        predicate.list.compactMap({ value -> BlockViewModel? in
            guard let model = self.document.getDefaultDetailsActiveModel(of: value) else { return nil }
            guard let viewModel = self.detailsConverter.convert(model, kind: value) else { return nil }
            return viewModel.configured(pageDetailsViewModel: self.defaultDetails())
        })
    }

    // MARK: - Events
    typealias Events = BaseDocument.Events
    func handle(events: Events) {
        self.document.handle(events: events)
    }
}
