//
//  EditorModule+Selection+Handler+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

protocol EditorModuleSelectionHandlerListProtocol {
    typealias SelectionEvent = EditorModule.Selection.IncomingEvent
    typealias SelectionCellEvent = EditorModule.Selection.IncomingCellEvent
    func selectionEnabled() -> Bool
    func set(selectionEnabled: Bool)
    
    func deselect(ids: [BlockId: BlockContentType])
    func select(ids: [BlockId: BlockContentType])
    
    func list() -> [BlockId]
    func clear()
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never>
}

protocol EditorModuleSelectionHandlerCellProtocol: class {
    func set(selected: Bool, id: BlockId, type: BlockContentType)
    func selected(id: BlockId) -> Bool

    func selectionCellEvent(_ id: BlockId) -> EditorModule.Selection.IncomingCellEvent
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorModule.Selection.IncomingCellEvent, Never>
}

protocol EditorModuleSelectionHandlerProtocol: EditorModuleSelectionHandlerListProtocol, EditorModuleSelectionHandlerCellProtocol {}

// MARK: Selection / Cell Protocol
/// Adopt this protocol by a cell or a cell (view?) model.
protocol EditorModuleSelectionCellProtocol {
    func getSelectionKey() -> BlockId?
    var selectionHandler: EditorModuleSelectionHandlerCellProtocol? {get}
}

extension EditorModuleSelectionCellProtocol {
    var selectionCellEvent: EditorModule.Selection.IncomingCellEvent? {
        guard let handler = self.selectionHandler, let id = self.getSelectionKey() else { return nil }
        return handler.selectionCellEvent(id)
    }
    var selectionCellEventPublisher: AnyPublisher<EditorModule.Selection.IncomingCellEvent, Never> {
        guard let handler = self.selectionHandler, let id = self.getSelectionKey() else { return .empty() }
        return handler.selectionCellEventPublisher(id)
    }
}

// MARK: Selection / DocumentViewModel Protocol
protocol EditorModuleHasSelectionHandlerProtocol: EditorModuleSelectionHandlerProtocol {
    var selectionHandler: EditorModuleSelectionHandlerProtocol? {get}
}

extension EditorModuleHasSelectionHandlerProtocol {
    func selectionEnabled() -> Bool {
        self.selectionHandler?.selectionEnabled() ?? false
    }
    
    func set(selectionEnabled: Bool) {
        self.selectionHandler?.set(selectionEnabled: selectionEnabled)
    }
    
    func deselect(ids: [BlockId: BlockContentType]) {
        self.selectionHandler?.deselect(ids: ids)
    }
    
    func select(ids: [BlockId: BlockContentType]) {
        self.selectionHandler?.select(ids: ids)
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
    
    func set(selected: Bool, id: BlockId, type: BlockContentType) {
        self.selectionHandler?.set(selected: selected, id: id, type: type)
    }
    
    func selected(id: BlockId) -> Bool {
        self.selectionHandler?.selected(id: id) ?? false
    }

    func selectionCellEvent(_ id: BlockId) -> EditorModule.Selection.IncomingCellEvent {
        self.selectionHandler?.selectionCellEvent(id) ?? .unknown
    }
    
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorModule.Selection.IncomingCellEvent, Never> {
        self.selectionHandler?.selectionCellEventPublisher(id) ?? .empty()
    }
}

// MARK: Selection / SelectionHandler Holder protocol
/// Should be adopted by Document View model.
protocol EditorModuleSelectionHandlerHolderProtocol: EditorModuleHasSelectionHandlerProtocol {
    func selectAll()
}

extension EditorModuleSelectionHandlerHolderProtocol {
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
