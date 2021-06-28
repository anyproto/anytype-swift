import BlocksModels
import Combine

struct BaseDocumentUpdateResult {
    var updates: EventHandlerUpdate
    var models: [BlockActiveRecordProtocol]
}

protocol BaseDocumentProtocol: AnyObject {
    var documentId: BlockId? { get }
    var defaultDetailsActiveModel: DetailsActiveModel { get }
    var userSession: BlockUserSessionModelProtocol? { get }
    var rootActiveModel: BlockActiveRecordProtocol? { get }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsData?, Never>
    func open(_ value: ServiceSuccess)
    func handle(events: PackOfEvents)
    /// Return publisher that received event on blocks update
    var updateBlockModelPublisher: AnyPublisher<BaseDocumentUpdateResult, Never> { get }
    
    func getDetails(by id: ParentId) -> DetailsActiveModel?
}
