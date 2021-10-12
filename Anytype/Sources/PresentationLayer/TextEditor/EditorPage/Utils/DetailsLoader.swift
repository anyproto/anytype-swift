import BlocksModels
import Combine
import AnytypeCore

class DetailsLoader {
    let document: BaseDocumentProtocol
    
    private var subscriptions = [BlockId: AnyCancellable]()
    
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func loadDetailsForBlockLink(blockId: BlockId, targetBlockId: BlockId) -> ObjectDetails? {
        guard let detailsModel = document.getDetails(id: targetBlockId) else {
            anytypeAssertionFailure("No block data id: \(targetBlockId) for block link")
            return nil
        }
        
        // TODO: - details. fix
//        let details = detailsModel.
//        subscriptions[blockId] = detailsModel.wholeDetailsPublisher.sink { [weak self] newDetails in
//            if details?.rawDetails != newDetails.rawDetails {
//                self?.eventProcessor.process(
//                    events: PackOfEvents(localEvent: .reload(blockId: blockId))
//                )
//            }
//        }
        
        return detailsModel
    }
}
