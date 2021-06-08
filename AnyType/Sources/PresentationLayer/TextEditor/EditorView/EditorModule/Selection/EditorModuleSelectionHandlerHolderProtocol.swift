import Foundation
import Combine
import BlocksModels

/// Should be adopted by Document View model.
protocol EditorModuleSelectionHandlerHolderProtocol: EditorModuleHasSelectionHandlerProtocol {
    func selectAll()
}

// MARK: Selection / DocumentViewModel Protocol
protocol EditorModuleHasSelectionHandlerProtocol: EditorModuleSelectionHandlerProtocol {
    var selectionHandler: EditorModuleSelectionHandlerProtocol {get}
}

extension EditorModuleHasSelectionHandlerProtocol {
    func selectionEnabled() -> Bool {
        selectionHandler.selectionEnabled()
    }
    
    func set(selectionEnabled: Bool) {
        selectionHandler.set(selectionEnabled: selectionEnabled)
    }
    
    func deselect(ids: [BlockId: BlockContentType]) {
        selectionHandler.deselect(ids: ids)
    }
    
    func select(ids: [BlockId: BlockContentType]) {
        selectionHandler.select(ids: ids)
    }
    
    func list() -> [BlockId] {
        selectionHandler.list()
    }
        
    func clear() {
        selectionHandler.clear()
    }
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never> {
        selectionHandler.selectionEventPublisher()
    }
    
    func set(selected: Bool, id: BlockId, type: BlockContentType) {
        selectionHandler.set(selected: selected, id: id, type: type)
    }
    
    func selected(id: BlockId) -> Bool {
        selectionHandler.selected(id: id)
    }

    func selectionCellEvent(_ id: BlockId) -> EditorSelectionIncomingCellEvent {
        selectionHandler.selectionCellEvent(id)
    }
    
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorSelectionIncomingCellEvent, Never> {
        selectionHandler.selectionCellEventPublisher(id)
    }
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
