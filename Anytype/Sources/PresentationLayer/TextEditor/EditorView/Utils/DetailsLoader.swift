import BlocksModels
import Combine

class DetailsLoader {
    let document: BaseDocumentProtocol
    let eventProcessor: EventProcessor
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        document: BaseDocumentProtocol,
        eventProcessor: EventProcessor
    ) {
        self.document = document
        self.eventProcessor = eventProcessor
    }
    
    func loadDetails(blockId: BlockId) -> DetailsData? {
        guard let details = document.getDetails(by: blockId) else {
            return nil
        }
        
        let model = DetailsActiveModel()
        model.wholeDetailsPublisher = details.wholeDetailsPublisher
        model.$currentDetails.sink { [weak self] details in
            self?.eventProcessor.process(events: PackOfEvents(localEvent: .reload(blockId: blockId)))
        }.store(in: &subscriptions)
        
        // TODO: open block 
        
        return details.currentDetails
    }    
}
