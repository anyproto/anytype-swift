import BlocksModels
import Combine

protocol BaseDocumentProtocol: AnyObject {
    var objectId: BlockId { get }
    
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsStorage: ObjectDetailsStorageProtocol { get }
    
    var onUpdateReceive: ((EventsListenerUpdate) -> Void)? { get set }
    
    func open()
    func getFlattenBlocks() -> [BlockModelProtocol]
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never>
    
}
