import Foundation
import Combine
import BlocksModels
import os


private extension Logging.Categories {
    static let viewModel: Self = "BlocksViews.DocumentViewModel"
}

extension BlocksViews {
    /// Purpose
    ///
    /// Subscribe on publishers of this class to receive information about state of the document.
    ///
    /// You could subscribe on **blocks or on details of opened document** from this class.
    ///
    class DocumentViewModel {
        typealias Document = BaseDocument
        private typealias ViewModelsConverter = BlocksViews.Supplement.ViewModelsConvertions.CompoundConverter
        private typealias DetailsViewModelsConverter = BlocksViews.Supplement.ViewModelsConvertions.Details.BaseConverter
        private var blocksConverter: ViewModelsConverter?
        private var detailsConverter: DetailsViewModelsConverter
        private(set) var document: Document
        
        /// TODO:
        /// Remove it later.
        ///
        /// We have to keep it private, but ok for now.
        ///
        var documentId: String? { self.document.documentId }
        
        init(_ document: Document = .init()) {
            self.document = document
            self.blocksConverter = .init(self.document)
            self.detailsConverter = .init(self.document)
        }

        // MARK: - Open
        func open(_ documentId: BlockId) {
            _ = self.document.open(documentId).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(value):
                    let logger = Logging.createLogger(category: .viewModel)
                    os_log(.debug, log: logger, "open(_ documentId). Error has occurred. %@", "\(value)")
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
        typealias BlockViewModel = BlocksViews.New.Base.ViewModel
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
        
        func defaultDetailsAccessor() -> InformationAccessor {
            self.document.getDefaultDetailsAccessor()
        }
        
        func defaultDetailsAccessorPublisher() -> AnyPublisher<InformationAccessor, Never> {
            self.document.getDefaultDetailsAccessorPublisher()
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
}
