import Foundation
import Combine
import os
import BlocksModels

// Sends and receives data via serivce.
class DetailsActiveModel {
    
    private var documentId: String?
    
    private let service = ObjectActionsService()
    
    // MARK: Publishers
    
    @Published private(set) var currentDetails: DetailsData?
    
    private(set) var wholeDetailsPublisher: AnyPublisher<DetailsData, Never> = .empty() {
        didSet {
            self.currentDetailsSubscription = self.wholeDetailsPublisher.sink { [weak self] (value) in
                self?.currentDetails = value
            }
        }
    }
    
    private var currentDetailsSubscription: AnyCancellable?
    private var eventSubject: PassthroughSubject<PackOfEvents, Never> = .init()
    
}

// MARK: Configuration

extension DetailsActiveModel {
    
    func configured(documentId: String) {
        self.documentId = documentId
    }
    
    func configured(publisher: AnyPublisher<DetailsData, Never>) {
        self.wholeDetailsPublisher = publisher
    }
    
    func configured(eventSubject: PassthroughSubject<PackOfEvents, Never>) {
        self.eventSubject = eventSubject
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
