//
//  DocumentViewModel+New+PageDetailsViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import os
import BlocksModels

fileprivate typealias Namespace = DocumentModule.DocumentViewModel

private extension Logging.Categories {
    static let pageDetailsViewModel: Self = "DocumentViewModel.PageDetailsViewModel"
}

extension Namespace {
    // Sends and receives data via serivce.
    class PageDetailsViewModel {
        typealias PageDetails = DetailsInformationModelProtocol
        typealias Builder = TopLevel.Builder
        typealias Details = TopLevel.AliasesMap.DetailsContent

        private var documentId: String?
        private var service: ServiceLayerModule.SmartBlockActionsService = .init()
        
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
extension Namespace.PageDetailsViewModel {
    func configured(documentId: String) -> Self {
        self.documentId = documentId
        self.setup()
        return self
    }
}

// MARK: Updates
extension Namespace.PageDetailsViewModel {
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
extension Namespace.PageDetailsViewModel {
    func receive(details: [Anytype_Rpc.Block.Set.Details.Detail]) {
        let modelDetails = BlocksModelsModule.Parser.Details.Converter.asModel(details: details)
        self.receive(details: Builder.detailsBuilder.informationBuilder.build(list: modelDetails))
    }
    
    func receive(details: PageDetails?) {
        self.wholeDetails = details
    }
}
