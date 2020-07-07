//
//  DocumentModule+Selection+Handler+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

protocol DocumentModuleSelectionHandlerListProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    typealias SelectionEvent = DocumentModule.Selection.IncomingEvent
    func selectionEnabled() -> Bool
    func set(selectionEnabled: Bool)
    
    func deselect(ids: Set<BlockId>)
    func select(ids: Set<BlockId>)
    
    func toggle(_ id: BlockId)
    func list() -> [BlockId]
    func clear()
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never>
}

protocol DocumentModuleSelectionHandlerCellProtocol: class {
    typealias BlockId = BlocksModels.Aliases.BlockId
    func set(selected: Bool, id: BlockId)
    func selected(id: BlockId) -> Bool
}

protocol DocumentModuleSelectionHandlerProtocol: DocumentModuleSelectionHandlerListProtocol, DocumentModuleSelectionHandlerCellProtocol {}

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
    var selectionHandler: DocumentModuleSelectionHandlerProtocol? {get}
}

extension DocumentModuleHasSelectionHandlerProtocol {
    func selectionEnabled() -> Bool {
        self.selectionHandler?.selectionEnabled() ?? false
    }
    
    func set(selectionEnabled: Bool) {
        self.selectionHandler?.set(selectionEnabled: selectionEnabled)
    }
    
    func deselect(ids: Set<BlocksModels.Aliases.BlockId>) {
        self.selectionHandler?.deselect(ids: ids)
    }
    
    func select(ids: Set<BlockId>) {
        self.selectionHandler?.select(ids: ids)
    }
            
    func toggle(_ id: BlockId) {
        self.selectionHandler?.toggle(id)
    }
    
    func list() -> [BlockId] {
        self.selectionHandler?.list() ?? []
    }
        
    func clear() {
        self.selectionHandler?.clear()
    }
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never> {
        self.selectionHandler?.selectionEventPublisher() ?? .empty()
    }
    
    func set(selected: Bool, id: BlocksModels.Aliases.BlockId) {
        self.selectionHandler?.set(selected: selected, id: id)
    }
    
    func selected(id: BlocksModels.Aliases.BlockId) -> Bool {
        self.selectionHandler?.selected(id: id) ?? false
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
