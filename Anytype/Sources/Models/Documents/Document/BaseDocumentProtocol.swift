import BlocksModels
import Combine


protocol PartialBaseDocument: AnyObject {
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsStorage: ObjectDetailsStorageProtocol { get }
    var objectRestrictions: ObjectRestrictions { get set }
}

protocol BaseDocumentProtocol: PartialBaseDocument {
    var objectId: BlockId { get }
    var onUpdateReceive: ((EventsListenerUpdate) -> Void)? { get set }
    var objectDetails: ObjectDetails? { get }
    var flattenBlocks: [BlockModelProtocol] { get }

    func open()

}
