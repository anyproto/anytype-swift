//
//  Details+Implementation.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os
import Combine

private extension Logging.Categories {
    static let blocksModelsDetails: Self = "BlocksModels.Details"
}

// MARK: DetailsContainer
extension Details {
    final class Container {
        typealias DetailsId = TopLevel.AliasesMap.BlockId
        typealias Model = DetailsModel
        
        private var models: [DetailsId: Model] = [:]
        
        func _choose(by id: DetailsId) -> ActiveRecord? {
            if let value = self.models[id] {
                return .init(container: self, nestedModel: value)
            }
            else {
                return nil
            }
        }
                        
        private func _get(by id: DetailsId) -> Model? {
            self.models[id]
        }
        
        private func _add(_ model: Model) {
            guard let parent = model.parent else {
                /// TODO: Add Logging
                /// We can't add details without parent. ( or block with details )
                let logger = Logging.createLogger(category: .blocksModelsDetails)
                os_log(.debug, log: logger, "We shouldn't add details with empty parent id. Skipping...")
                return
            }
            
            if self.models[parent] != nil {
                let logger = Logging.createLogger(category: .blocksModelsDetails)
                os_log(.debug, log: logger, "We shouldn't replace details by add operation. Skipping...")
                return
            }
            self.models[parent] = model
        }
        
        private func _remove(by id: DetailsId) {
            guard self.models.keys.contains(id) else {
                let logger = Logging.createLogger(category: .blocksModelsDetails)
                os_log(.debug, log: logger, "We shouldn't delete models if they are not in the collection. Skipping...")
                return
            }
            self.models.removeValue(forKey: id)
        }
    }
}

extension Details.Container: DetailsContainerModelProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<DetailsId> { .init(self.models.keys.makeIterator()) }
    // MARK: - Operations / Choose
    func choose(by id: DetailsId) -> DetailsActiveRecordModelProtocol? { self._choose(by: id) }
    // MARK: - Operations / Get
    func get(by id: DetailsId) -> DetailsModelProtocol? { self._get(by: id) }
    // MARK: - Operations / Remove
    func remove(_ id: DetailsId) { self._remove(by: id) }
    // MARK: - Operations / Add
    func add(_ model: DetailsModelProtocol) {
        let ourModel: Model = .init(details: model.details)
        self._add(ourModel)
    }
}

extension Details {
    class DetailsModel: ObservableObject {
        /// Its a Details model.
        /// It has PageDetails (?)

        /// TODO: Rename later to information.
        @Published var _details: DetailsInformationModelProtocol
        required init(details: DetailsInformationModelProtocol) {
            self._details = details
        }
    }
    
    class ActiveRecord {
        /// Represents chosen details over this container.
        /// Can switch to another details if needed. (?)
        typealias DetailsId = TopLevel.AliasesMap.BlockId
        typealias Container = Details.Container
        typealias NestedModel = DetailsModel
        private weak var _container: Container?
        private var _nestedModel: NestedModel
        init(container: Container, nestedModel: NestedModel) {
            self._container = container
            self._nestedModel = nestedModel
        }
        required init(_ chosen: ActiveRecord) {
            self._container = chosen._container
            self._nestedModel = chosen._nestedModel
        }
        class func create(_ chosen: ActiveRecord) -> Self { .init(chosen) }

    }
}

extension Details.DetailsModel: DetailsModelProtocol {
    var details: DetailsInformationModelProtocol {
        get {
            self._details
        }
        set {
            /// TODO:
            /// Refactor later.
            ///
            /// Check if parent ids are not equal.
            /// If so, take parent id and set it to new value.
            ///
            
            var newValue = newValue
            if self._details.parentId != newValue.parentId {
                newValue.parentId = self._details.parentId
            }
            self._details = newValue
        }
    }
        
    /// TODO: Add parent to model or extend PageDetails to store parentId.
    var parent: DetailsId? {
        get {
            self._details.parentId
        }
        set {
            self._details.parentId = newValue
        }
    }
    
    func didChangeInformationPublisher() -> AnyPublisher<DetailsInformationModelProtocol, Never> {
        self.$_details.eraseToAnyPublisher()
    }
}

extension Details.ActiveRecord: DetailsActiveRecordModelProtocol {
    var container: DetailsContainerModelProtocol? {
        self._container
    }
    var detailsModel: DetailsModelProtocol {
        self._nestedModel
    }
    func didChangeInformationPublisher() -> AnyPublisher<DetailsInformationModelProtocol, Never> {
        self.detailsModel.didChangeInformationPublisher()
    }
}
