import Combine
import BlocksModels


protocol DocumentViewModelProtocol {
    var documentId: String? { get } // TODO: Remove
    var rootActiveModel: BaseDocument.ActiveModel? { get }
    var userSession: BaseDocument.UserSession? { get }
    
    func open(_ value: ServiceSuccess)
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never>
    func pageDetailsPublisher() -> AnyPublisher<DetailsInformationProvider, Never>
    
    func detailsViewModels(orderedBy predicate: DocumentViewModelPredicate) -> [BaseBlockViewModel]
    func detailsViewModels() -> [BaseBlockViewModel]
    func handle(events: BaseDocument.Events)
}
