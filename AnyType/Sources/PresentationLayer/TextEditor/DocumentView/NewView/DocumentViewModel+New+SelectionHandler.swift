//
//  DocumentViewModel+New+SelectionHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os

private extension Logging.Categories {
    static let selectionHandler: Self = "DocumentModule.DocumentViewModel.SelectionHandler"
}

fileprivate typealias Namespace = DocumentModule

extension Namespace.SelectionHandler {
    struct Storage {
        typealias Id = BlocksModels.Aliases.BlockId
        typealias Ids = Set<Id>
        /// Selected ids that user has selected.
        private var selectedIds: Ids = .init()
        
        /// Flag that determines if user initiates selection mode.
        private var isSelectionEnabled: Bool = false {
            didSet {
                if !self.isSelectionEnabled {
                    self.clear()
                }
            }
        }
        
        // MARK: Selection
        func selectionEnabled() -> Bool { self.isSelectionEnabled }
        mutating func toggleSelectionEnabled() { self.isSelectionEnabled.toggle() }
        mutating func startSelection() { self.isSelectionEnabled = true }
        mutating func stopSelection() { self.isSelectionEnabled = false }
        
        // MARK: Ids
        func isEmpty() -> Bool { self.selectedIds.isEmpty }
        func count() -> Int { self.selectedIds.count }
        func listSelectedIds() -> [Id] { .init(self.selectedIds) }
        func contains(id: Id) -> Bool { self.selectedIds.contains(id) }
        mutating func set(ids: Ids) { self.selectedIds = ids }
        mutating func clear() { self.selectedIds = .init() }
        mutating func toggle(id: Id) { self.selectedIds.contains(id) ? self.remove(id: id) : self.add(id: id) }
        mutating func add(id: Id) { self.selectedIds.insert(id) }
        mutating func remove(id: Id) { self.selectedIds.remove(id) }
    }
}

extension Namespace {
    class SelectionHandler {
        typealias SelectionEvent = DocumentModule.SelectionEvent
        /// Publishers
        private var subscription: AnyCancellable?
        private var storageEventsSubject: PassthroughSubject<SelectionEvent, Never> = .init()
        private var storageEventsPublisher: AnyPublisher<SelectionEvent, Never> = .empty()
        /// Storage
        @Published private var storage: Storage = .init() {
            didSet {
                self.subscription = self.$storage.sink { [weak self] (value) in
                    self?.handle(value)
                }
            }
        }
        
        /// Updates
        private func storageEvent(from storage: Storage) -> SelectionEvent {
            if !storage.selectionEnabled() {
                return .selectionDisabled
            }
            if storage.isEmpty() {
                return .selectionEnabled
            }
            return .selectionEnabled(.nonEmpty(.init(storage.count())))
        }
        
        private func handle(_ storageUpdate: Storage) {
            self.storageEventsSubject.send(self.storageEvent(from: storageUpdate))
        }
        
        /// Setup
        func setup() {
            self.storageEventsPublisher = self.storageEventsSubject.eraseToAnyPublisher()
        }
        
        // MARK: - Initialization
        init() {
            self.setup()
        }
    }
}

extension Namespace {
    enum SelectionEvent {
        enum CountEvent {
            static var `default`: Self = .isEmpty
            case isEmpty
            case nonEmpty(UInt)
            static func from(_ value: Int) -> Self {
                value <= 0 ? .isEmpty : nonEmpty(.init(value))
            }
        }
        case selectionDisabled
        case selectionEnabled(CountEvent)
        static var selectionEnabled: Self = .selectionEnabled(.default)
    }
}

protocol DocumentModuleSelectionHandlerProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    typealias SelectionEvent = DocumentModule.SelectionEvent
    func selectionEnabled() -> Bool
    func set(selectionEnabled: Bool)
    
    func select(ids: Set<BlockId>)
    
    func toggle(_ id: BlockId)
    func list() -> [BlockId]
    func clear()
    
    func selectionEventPublisher() -> AnyPublisher<DocumentModule.SelectionEvent, Never>
}

extension Namespace.SelectionHandler: DocumentModuleSelectionHandlerProtocol {
    func selectionEnabled() -> Bool {
        self.storage.selectionEnabled()
    }
    
    func set(selectionEnabled: Bool) {
        if self.storage.selectionEnabled() != selectionEnabled {
            self.storage.toggleSelectionEnabled()
        }
    }
    
    func select(ids: Set<BlockId>) {
        self.storage.set(ids: ids)
    }
                
    func toggle(_ id: BlockId) {
        self.storage.toggle(id: id)
    }
    
    func list() -> [BlockId] {
        self.storage.listSelectedIds()
    }
    
    func clear() {
        self.storage.clear()
    }
    
    func selectionEventPublisher() -> AnyPublisher<DocumentModule.SelectionEvent, Never> {
        self.storageEventsPublisher
    }
}

protocol DocumentModuleSelectionHandlerCellProtocol: class {
    typealias BlockId = BlocksModels.Aliases.BlockId
    func set(selected: Bool, id: BlockId)
    func selected(id: BlockId) -> Bool
}

extension Namespace.SelectionHandler: DocumentModuleSelectionHandlerCellProtocol {
    func set(selected: Bool, id: BlockId) {
        let contains = self.storage.contains(id: id)
        if contains != selected {
            self.storage.toggle(id: id)
        }
    }
    func selected(id: BlockId) -> Bool {
        self.storage.contains(id: id)
    }
}

// MARK: Selection / Cell Protocol
/// Adopt this protocol by a cell or a cell (view?) model.
protocol DocumentModuleSelectionCellProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    func getSelectionKey() -> BlockId?
    var selectionHandler: DocumentModuleSelectionHandlerCellProtocol? {get}
}

extension DocumentModuleSelectionCellProtocol {
    var isSelected: Bool {
        get {
            if let key = self.getSelectionKey(), let handler = self.selectionHandler {
                return handler.selected(id: key)
            }
            return false
        }
        set {
            if let key = self.getSelectionKey(), let handler = self.selectionHandler {
                handler.set(selected: newValue, id: key)
            }
        }
    }
}

// MARK: Selection / DocumentViewModel Protocol
protocol DocumentModuleHasSelectionHandlerProtocol: DocumentModuleSelectionHandlerProtocol {
    var selectionHandler: DocumentModuleSelectionHandlerProtocol {get}
}

extension DocumentModuleHasSelectionHandlerProtocol {
    func selectionEnabled() -> Bool {
        self.selectionHandler.selectionEnabled()
    }
    
    func set(selectionEnabled: Bool) {
        self.selectionHandler.set(selectionEnabled: selectionEnabled)
    }
        
    func select(ids: Set<BlockId>) {
        self.selectionHandler.select(ids: ids)
    }
            
    func toggle(_ id: BlockId) {
        self.selectionHandler.toggle(id)
    }
    
    func list() -> [BlockId] {
        self.selectionHandler.list()
    }
        
    func clear() {
        self.selectionHandler.clear()
    }
    
    func selectionEventPublisher() -> AnyPublisher<DocumentModule.SelectionEvent, Never> {
        self.selectionHandler.selectionEventPublisher()
    }
}

// MARK: Selection / SelectionHandler Holder protocol
/// Should be adopted by Document View model.
protocol DocumentModuleSelectionHandlerHolderProtocol: DocumentModuleHasSelectionHandlerProtocol {
    func selectAll()
}

extension DocumentModuleSelectionHandlerHolderProtocol {
    func deselectAll() {
        self.clear()
    }
    func done() {
        self.clear()
    }
    func isEmpty() -> Bool {
        self.list().isEmpty
    }
}

extension DocumentModule.DocumentViewModel: DocumentModuleSelectionHandlerHolderProtocol {
    func selectAll() {
        /// take all ids
        guard let model = self.rootModel, let rootId = model.rootId else {
            return
        }
        
        /// TODO: Find all childrenIds.
        /// But for now it is ok.
        /// Let's iterate over them later.
        guard let childrenIds = model.choose(by: rootId)?.childrenIds() else {
            return
        }
        
        self.select(ids: .init(childrenIds))
    }
}
