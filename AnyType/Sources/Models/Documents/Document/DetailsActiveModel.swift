import Foundation
import Combine
import os
import BlocksModels

// Sends and receives data via serivce.
class DetailsActiveModel {
    
    private var documentId: String?
    
    /// TODO:
    /// Add DI later.
    /// Or remove service from this model completely.
    /// We could use events/actions and send them directly to `user interaction handler`, which will send result to `event handler`.
    ///
    private let service: ObjectActionsService = .init()
    
    // MARK: Publishers
    
    @Published private(set) var currentDetails: DetailsInformationProvider = TopLevelBuilderImpl.detailsBuilder.informationBuilder.empty()
    private(set) var wholeDetailsPublisher: AnyPublisher<DetailsInformationModel, Never> = .empty() {
        didSet {
            self.currentDetailsSubscription = self.wholeDetailsPublisher.sink { [weak self] (value) in
                self?.currentDetails = value
            }
        }
    }
    
    private var currentDetailsSubscription: AnyCancellable?
    private var eventSubject: PassthroughSubject<EventListening.PackOfEvents, Never> = .init()
    
}

// MARK: Configuration

extension DetailsActiveModel {
    
    func configured(documentId: String) {
        self.documentId = documentId
    }
    
    func configured(publisher: AnyPublisher<DetailsInformationModel, Never>) {
        self.wholeDetailsPublisher = publisher
    }
    
    func configured(eventSubject: PassthroughSubject<EventListening.PackOfEvents, Never>) {
        self.eventSubject = eventSubject
    }
    
}

// MARK: Updates

extension DetailsActiveModel {
    
    /// Maybe add AnyPublisher as Return result?
    
    func update(details: [DetailsContent]) -> AnyPublisher<Void, Error>? {
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
                    .init(
                        contextId: value.contextID,
                        events: value.messages,
                        ourEvents: []
                    )
                )
            }
        )
        .successToVoid()
        .eraseToAnyPublisher()
    }
    
}
