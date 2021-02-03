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
        private var converter: ViewModelsConverter?
        private var document: Document
        
        /// TODO:
        /// Remove it later.
        /// 
        /// We have to keep it private, but ok for now.
        ///
        var documentId: String? { self.document.documentId }
        
        init(_ document: Document = .init()) {
            self.document = document
            self.converter = .init(self.document)
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
        self.converter?.convert(models) ?? []
    }
    
    func updatePublisher() -> AnyPublisher<UpdateResult, Never> {
        self.document.modelsAndUpdatePublisher().map { [weak self] (value) in
            .init(updates: value.updates, models: self?.viewModels(from: value.models) ?? [])
        }.eraseToAnyPublisher()
    }
}

// MARK: - Details
extension FileNamespace {
    struct Predicate {
        var list: [TopLevel.AliasesMap.DetailsContent.Kind] = [.title]
    }
    
    func defaultDetails() -> DocumentModule.Document.BaseDocument.DetailsActiveModel {
        self.document.getDefaultDetails()
    }
    
    func defaultDetailsAccessor() -> AnyPublisher<DocumentModule.Document.BaseDocument.DetailsAccessor, Never> {
        self.document.getDefaultDetailsAccessor()
    }
    
    /// TODO: Implement it later.
    func defaultDetailsViewModels(orderedBy predicate: Predicate) -> [BlockViewModel] {
        []
    }
}

// MARK: - Events
extension FileNamespace {
    typealias Events = DocumentModule.Document.BaseDocument.Events
    func handle(events: Events) {
        self.document.handle(events: events)
    }
}
