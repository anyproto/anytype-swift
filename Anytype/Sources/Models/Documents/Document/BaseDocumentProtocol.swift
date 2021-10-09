import BlocksModels
import Combine

struct BaseDocumentUpdateResult {
    var updates: EventHandlerUpdate
    var details: DetailsDataProtocol?
    var models: [BlockModelProtocol]
}

protocol BaseDocumentProtocol: AnyObject {
    var documentId: BlockId? { get }
    var userSession: UserSession? { get set }
    var rootActiveModel: BlockModelProtocol? { get }
    var rootModel: RootBlockContainer? { get }
    var eventHandler: EventHandler { get }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never>
    func open(_ value: ResponseEvent)
    func handle(events: PackOfEvents)
    /// Return publisher that received event on blocks update
    var updateBlockModelPublisher: AnyPublisher<BaseDocumentUpdateResult, Never> { get }
    
    func getDetails(id: BlockId) -> DetailsDataProtocol?
}
