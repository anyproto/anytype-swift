import BlocksModels
import Combine

struct BaseDocumentUpdateResult {
    var updates: EventHandlerUpdate
    var details: DetailsData?
    var models: [BlockModelProtocol]
}

protocol BaseDocumentProtocol: AnyObject {
    var documentId: BlockId? { get }
    var defaultDetailsActiveModel: DetailsActiveModel { get }
    var userSession: UserSession? { get set }
    var rootActiveModel: BlockModelProtocol? { get }
    var rootModel: RootBlockContainer? { get }
    var eventHandler: EventHandler { get }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsData?, Never>
    func open(_ value: ServiceSuccess)
    func handle(events: PackOfEvents)
    /// Return publisher that received event on blocks update
    var updateBlockModelPublisher: AnyPublisher<BaseDocumentUpdateResult, Never> { get }
    
    func getDetails(by id: ParentId) -> DetailsActiveModel?
}
