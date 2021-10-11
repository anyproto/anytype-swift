import BlocksModels
import Combine

struct BaseDocumentUpdateResult {
    var updates: EventHandlerUpdate
    var details: ObjectDetails?
    var models: [BlockModelProtocol]
}

protocol BaseDocumentProtocol: AnyObject {
    var objectId: BlockId { get }
    var userSession: UserSession? { get set }
    var rootActiveModel: BlockModelProtocol? { get }
    var rootModel: RootBlockContainer? { get }
    var eventHandler: EventHandler { get }
    
    func open()
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never>
    func handle(events: PackOfEvents)
    /// Return publisher that received event on blocks update
    var updateBlockModelPublisher: AnyPublisher<BaseDocumentUpdateResult, Never> { get }
    
    func getDetails(id: BlockId) -> DetailsDataProtocol?
}
