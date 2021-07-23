//
//  DocumentViewModel+PageDetailsViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import os

private extension Logging.Categories {
    static let pageDetailsViewModel: Self = "DocumentViewModel.PageDetailsViewModel"
}

extension DocumentViewModel {
    // Sends and receives data via serivce.
    class PageDetailsViewModel {
        typealias Details = BlockModels.Block.Information.Details
        typealias PageDetails = BlockModels.Block.Information.PageDetails

        private var documentId: String?
        private var service: SmartBlockActionsService = .init()
        
        // MARK: Publishers
        @Published private var wholeDetails: PageDetails?
        var wholeDetailsPublisher: AnyPublisher<PageDetails, Never> = .empty()
        
        // MARK: Setup
        func setup() {
            self.setupPublishers()
        }
        
        func setupPublishers() {
            self.wholeDetailsPublisher = self.$wholeDetails.safelyUnwrapOptionals().eraseToAnyPublisher()
        }
    }
}

// MARK: Configuration
extension DocumentViewModel.PageDetailsViewModel {
    func configured(documentId: String) -> Self {
        self.documentId = documentId
        self.setup()
        return self
    }
}

// MARK: Updates
extension DocumentViewModel.PageDetailsViewModel {
    private enum UpdateScheduler {
        static let defaultTimeInterval: RunLoop.SchedulerTimeType.Stride = 5.0
    }
    
    /// Maybe add AnyPublisher as Return result?
    func update(details: Details) -> AnyPublisher<Void, Error>? {
        self.documentId.flatMap({
            self.service.setDetails.action(contextID: $0, details: BlockModels.Parser.Details.Converter.asMiddleware(models: [details])).eraseToAnyPublisher()
        })
    }
}

// MARK: Receive
extension DocumentViewModel.PageDetailsViewModel {
    func receive(details: [Anytype_Rpc.Block.Set.Details.Detail]) {
        let modelDetails = BlockModels.Parser.Details.Converter.asModel(details: details)
        self.receive(details: .init(modelDetails))
    }
    
    func receive(details: PageDetails?) {
        self.wholeDetails = details
    }
}
