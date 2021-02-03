//
//  DocumentModule+Document+DetailsActiveModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import os
import BlocksModels

fileprivate typealias Namespace = DocumentModule.Document
fileprivate typealias FileNamespace = DocumentModule.Document.DetailsActiveModel

private extension Logging.Categories {
    static let detailsActiveModel: Self = "DocumentModule.Document.DetailsActiveModel"
}

/// TODO: Rethink API.
/// It is too complex now.
extension Namespace {
    // Sends and receives data via serivce.
    class DetailsActiveModel {
        typealias PageDetails = DetailsInformationModelProtocol
        typealias Builder = TopLevel.Builder
        typealias Details = TopLevel.AliasesMap.DetailsContent

        private var documentId: String?
        
        /// TODO:
        /// Add DI later.
        private var service: ServiceLayerModule.SmartBlockActionsService = .init()
        
        // MARK: Publishers
        @Published private var wholeDetails: PageDetails?
        @Published private(set) var currentDetails: PageDetails?
        private(set) var wholeDetailsPublisher: AnyPublisher<PageDetails, Never> = .empty() {
            didSet {
                self.currentDetailsSubscription = self.wholeDetailsPublisher.sink { [weak self] (value) in
                    self?.currentDetails = value
                }
            }
        }
        var currentDetailsSubscription: AnyCancellable?
        
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
extension FileNamespace {
    func configured(documentId: String) -> Self {
        self.documentId = documentId
        self.setup()
        return self
    }
    
    func configured(publisher: AnyPublisher<PageDetails, Never>) {
        self.wholeDetailsPublisher = publisher
    }
}

// MARK: Updates
extension FileNamespace {
    private enum UpdateScheduler {
        static let defaultTimeInterval: RunLoop.SchedulerTimeType.Stride = 5.0
    }
    
    /// Maybe add AnyPublisher as Return result?
    func update(details: Details) -> AnyPublisher<Void, Error>? {
        self.documentId.flatMap({
            self.service.setDetails.action(contextID: $0, details: BlocksModelsModule.Parser.Details.Converter.asMiddleware(models: [details])).eraseToAnyPublisher()
        })
    }
}

// MARK: Receive
extension FileNamespace {
    func receive(details: [Anytype_Rpc.Block.Set.Details.Detail]) {
        let modelDetails = BlocksModelsModule.Parser.Details.Converter.asModel(details: details)
        self.receive(details: Builder.detailsBuilder.informationBuilder.build(list: modelDetails))
    }
    
    func receive(details: PageDetails?) {
        self.wholeDetails = details
    }
}
