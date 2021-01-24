//
//  BlocksViews+NewSupplement+UserInteractionHandler+IndexWalker.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.12.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os
import SwiftProtobuf
import BlocksModels

fileprivate typealias Namespace = BlocksViews.Supplement.UserInteractionHandler

private extension Logging.Categories {
    static let textEditorUserInteractorHandlerIndexWalker: Self = "TextEditor.UserInteractionHandler.IndexWalker"
}

extension Namespace {
    class LinearIndexWalker {
        typealias Model = BlockActiveRecordModelProtocol
        
        private var models: [Model] = []
        var listModelsProvider: UserInteractionHandlerListModelsProvider
        init(_ listModelsProvider: UserInteractionHandlerListModelsProvider) {
            self.listModelsProvider = listModelsProvider
        }
    }
}

// MARK: Search
extension Namespace.LinearIndexWalker {
    func model(beforeModel model: Model, includeParent: Bool, onlyFocused: Bool = true) -> Model? {
        /// Do we actually need parent?
        guard let modelIndex = self.models.firstIndex(where: { $0.blockModel.information.id == model.blockModel.information.id }) else { return nil }
        
        /// Iterate back
        var index = self.models.index(before: modelIndex)
        let startIndex = self.models.startIndex
        
        /// TODO:
        /// Look at documentation how we should handle different blocks types.
        while index >= startIndex {
            let object = self.models[index]
            switch object.blockModel.information.content {
            case let .text(value): return object
            case let .layout(value) where value.style == .div: index = self.models.index(before: index)
            default: return nil
            }
        }
        
        return nil
    }
}

// MARK: Configuration
extension Namespace.LinearIndexWalker {
    private func configured(models: [Model]) {
        self.models = models
    }
    
    private func configured(listModelsProvider: UserInteractionHandlerListModelsProvider) {
        self.listModelsProvider = listModelsProvider
    }
    
    func renew() {
        self.configured(models: self.listModelsProvider.getModels)
    }
}

// MARK: ListModelsProvider
protocol UserInteractionHandlerListModelsProvider {
    var getModels: [BlockActiveRecordModelProtocol] {get}
}

extension Namespace {
    struct DocumentModelListProvider: UserInteractionHandlerListModelsProvider {
        private typealias ViewModel = DocumentModule.Document.ViewController.ViewModel
        private weak var model: ViewModel?
        private var _models: [BlockActiveRecordModelProtocol] = [] // Do we need cache?
        init(model: DocumentModule.Document.ViewController.ViewModel) {
            self.model = model
        }
        var getModels: [BlockActiveRecordModelProtocol] {
            self.model?.builders.compactMap({($0 as! ViewModel.BlocksViewsNamespace.Base.ViewModel).getBlock()}) ?? []
        }
    }
}
