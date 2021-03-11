//
//  BlocksViews+Document+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import os

fileprivate typealias Namespace = BlocksViews.Document
fileprivate typealias FileNamespace = BlocksViews.Document.ViewModel

private extension Logging.Categories {
    static let viewModel: Self = "BlocksViews.Document.ViewModel"
}

extension Namespace {
    /// Purpose
    ///
    /// Subscribe on publishers of this class to receive information about state of the document.
    ///
    /// You could subscribe on **blocks or on details of opened document** from this class.
    ///
    class ViewModel {
        typealias Document = DocumentModule.Document.BaseDocument
        private typealias ViewModelsConverter = BlocksViews.Supplement.ViewModelsConvertions.CompoundConverter
        private typealias DetailsViewModelsConverter = BlocksViews.Supplement.ViewModelsConvertions.Details.BaseConverter
        private var blocksConverter: ViewModelsConverter?
        private var detailsConverter: DetailsViewModelsConverter
        private(set) var document: Document
        
        /// TODO:
        /// Remove it later.
        ///
        /// We have to keep it private, but ok for now.
        ///
        var documentId: String? { self.document.documentId }
        
        init(_ document: Document = .init()) {
            self.document = document
            self.blocksConverter = .init(self.document)
            self.detailsConverter = .init(self.document)
        }
    }
}

// MARK: - Open
extension FileNamespace {
    func open(_ documentId: DocumentModule.Document.BaseDocument.BlockId) {
        _ = self.document.open(documentId).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(value):
                let logger = Logging.createLogger(category: .viewModel)
                os_log(.debug, log: logger, "open(_ documentId). Error has occurred. %@", "\(value)")
            }
        }, receiveValue: {})
    }
    func open(_ documentId: DocumentModule.Document.BaseDocument.BlockId) -> AnyPublisher<Void, Error> {
        self.document.open(documentId)
    }
    func open(_ value: ServiceLayerModule.Success) {
        self.document.open(value)
    }
}

// MARK: - ViewModels
extension FileNamespace {
    typealias BlockViewModel = BlocksViews.New.Base.ViewModel
    struct UpdateResult {
        var updates: DocumentModule.Document.BaseDocument.ModelsUpdates
        var models: [BlockViewModel]
    }
    
    private func viewModels(from models: [DocumentModule.Document.BaseDocument.ActiveModel]) -> [BlockViewModel] {
        self.blocksConverter?.convert(models) ?? []
    }
    
    func updatePublisher() -> AnyPublisher<UpdateResult, Never> {
        self.document.modelsAndUpdatesPublisher().map { [weak self] (value) in
            .init(updates: value.updates, models: self?.viewModels(from: value.models) ?? [])
        }.eraseToAnyPublisher()
    }
}

// MARK: - Models
extension FileNamespace {
    func getRootActiveModel() -> DocumentModule.Document.BaseDocument.ActiveModel? {
        self.document.getRootActiveModel()
    }
    func getUserSession() -> DocumentModule.Document.BaseDocument.UserSession? {
        self.document.getUserSession()
    }
}

// MARK: - Details
extension FileNamespace {
    struct Predicate {
        var list: [TopLevel.AliasesMap.DetailsContent.Kind] = [.iconEmoji, .title]
    }
    
    func defaultDetails() -> DocumentModule.Document.BaseDocument.DetailsActiveModel {
        self.document.getDefaultDetails()
    }
    
    func defaultDetailsAccessor() -> DocumentModule.Document.BaseDocument.DetailsAccessor {
        self.document.getDefaultDetailsAccessor()
    }
    
    func defaultDetailsAccessorPublisher() -> AnyPublisher<DocumentModule.Document.BaseDocument.DetailsAccessor, Never> {
        self.document.getDefaultDetailsAccessorPublisher()
    }
    
    func defaultDetailsViewModels(orderedBy predicate: Predicate = .init()) -> [BlockViewModel] {
        predicate.list.compactMap({ value -> BlockViewModel? in
            guard let model = self.document.getDefaultDetailsActiveModel(of: value) else { return nil }
            guard let viewModel = self.detailsConverter.convert(model, kind: value) else { return nil }
            return viewModel.configured(pageDetailsViewModel: self.defaultDetails())
        })
    }
}

// MARK: - Events
extension FileNamespace {
    typealias Events = DocumentModule.Document.BaseDocument.Events
    func handle(events: Events) {
        self.document.handle(events: events)
    }
}
