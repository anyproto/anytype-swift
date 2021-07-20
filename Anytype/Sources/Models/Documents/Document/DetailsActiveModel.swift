import Foundation
import Combine
import os
import BlocksModels

// Sends and receives data via serivce.
class DetailsActiveModel {
    
    var documentId: String?
    var eventSubject: PassthroughSubject<PackOfEvents, Never> = .init()
    var wholeDetailsPublisher: AnyPublisher<DetailsData, Never> {
        didSet {
            self.currentDetailsSubscription = self.wholeDetailsPublisher.sink { [weak self] (value) in
                self?.currentDetails = value
            }
        }
    }
    
    @Published private(set) var currentDetails: DetailsData?
    
    private var currentDetailsSubscription: AnyCancellable?
    private let service = ObjectActionsService()
    
    init(
        documentId: String? = nil,
        wholeDetailsPublisher: AnyPublisher<DetailsData, Never> = .empty()
    ) {
        self.documentId = documentId
        self.wholeDetailsPublisher = wholeDetailsPublisher
    }
}


// MARK: Updates

extension DetailsActiveModel {
    
    /// Maybe add AnyPublisher as Return result?
    
    func update(details: [DetailsKind: DetailsEntry<AnyHashable>]) -> AnyPublisher<Void, Error>? {
        guard let documentId = self.documentId else {
            assertionFailure("update(details:). Our document is not ready yet")
            return nil
        }
        
        return self.service.setDetails(
            contextID: documentId,
            details: details
        )
        .handleEvents(
            receiveOutput: { [weak self] (value) in
                self?.eventSubject.send(
                    PackOfEvents(middlewareEvents: value.messages)
                )
            }
        )
        .successToVoid()
        .eraseToAnyPublisher()
    }
    
}
