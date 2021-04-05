//
//  DocumentModule+Document+DetailsActiveModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import os
import BlocksModels

private extension Logging.Categories {
    static let detailsActiveModel: Self = "DocumentModule.Document.DetailsActiveModel"
}

// Sends and receives data via serivce.
class DetailsActiveModel {
    typealias PageDetails = DetailsInformationModelProtocol
    typealias Builder = TopLevel.Builder
    typealias Details = DetailsContent
    typealias Events = EventListening.PackOfEvents
    private var documentId: String?
    
    /// TODO:
    /// Add DI later.
    /// Or remove service from this model completely.
    /// We could use events/actions and send them directly to `user interaction handler`, which will send result to `event handler`.
    ///
    private var service: SmartBlockActionsService = .init()
    
    // MARK: Publishers
    @Published private(set) var currentDetails: PageDetails = TopLevel.Builder.detailsBuilder.informationBuilder.empty()
    private(set) var wholeDetailsPublisher: AnyPublisher<PageDetails, Never> = .empty() {
        didSet {
            self.currentDetailsSubscription = self.wholeDetailsPublisher.sink { [weak self] (value) in
                self?.currentDetails = value
            }
        }
    }
    var currentDetailsSubscription: AnyCancellable?
    private var eventSubject: PassthroughSubject<Events, Never> = .init()
}

// MARK: Configuration
extension DetailsActiveModel {
    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }
    
    func configured(publisher: AnyPublisher<PageDetails, Never>) {
        self.wholeDetailsPublisher = publisher
    }
    
    func configured(eventSubject: PassthroughSubject<Events, Never>) {
        self.eventSubject = eventSubject
    }
}

// MARK: Handle Events
extension DetailsActiveModel {
    private func handle(events: Events) {
        self.eventSubject.send(events)
    }
}

// MARK: Updates
extension DetailsActiveModel {
    private enum UpdateScheduler {
        static let defaultTimeInterval: RunLoop.SchedulerTimeType.Stride = 5.0
    }
    
    /// Maybe add AnyPublisher as Return result?
    func update(details: Details) -> AnyPublisher<Void, Error>? {
        guard let documentId = self.documentId else {
            let logger = Logging.createLogger(category: .detailsActiveModel)
            os_log(.debug, log: logger, "update(details:). Our document is not ready yet")
            return nil
        }
        
        return self.service.setDetails(contextID: documentId, details: details).handleEvents(receiveOutput: { [weak self] (value) in
            self?.handle(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
        }).successToVoid().eraseToAnyPublisher()
    }
}
