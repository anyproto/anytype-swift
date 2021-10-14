import BlocksModels
import Combine

struct BaseDocumentUpdateResult {
    let updates: EventsListenerUpdate
    let details: ObjectDetails?
    let models: [BlockModelProtocol]
}

protocol BaseDocumentProtocol: AnyObject {
    var objectId: BlockId { get }
    
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsStorage: ObjectDetailsStorageProtocol { get }
    
    var onUpdateReceive: ((BaseDocumentUpdateResult) -> Void)? { get set }
    
    func open()
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never>
    
}
