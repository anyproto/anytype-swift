import Combine
import BlocksModels

/// Subscribe on publishers of this class to receive information about state of the document.
protocol DocumentViewModelProtocol {
    var documentId: String? { get } // TODO: Remove
    var rootActiveModel: BaseDocument.ActiveModel? { get }
    var userSession: BaseDocument.UserSession? { get }
    var defaultDetailsActiveModel: DetailsActiveModel { get }
    
    func open(_ value: ServiceSuccess)
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never>
    func pageDetailsPublisher() -> AnyPublisher<DetailsEntryValueProvider, Never>
    
    func handle(events: BaseDocument.Events)
}
