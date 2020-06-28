//
//  DocumentModule+Selection+Handler.swift
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

fileprivate typealias Namespace = DocumentModule.Selection

extension Namespace.Handler {
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
    class Handler {
        typealias SelectionEvent = DocumentModule.Selection.IncomingEvent
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
    enum IncomingEvent {
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

extension Namespace.Handler: DocumentModuleSelectionHandlerProtocol {
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
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never> {
        self.storageEventsPublisher
    }
    
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
