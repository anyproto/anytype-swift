import Foundation
import Combine
import BlocksModels

/// Should be adopted by Document View model.
protocol EditorModuleSelectionHandlerHolderProtocol: EditorModuleHasSelectionHandlerProtocol {
    func selectAll()
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

    func selectionCellEvent(_ id: BlockId) -> EditorSelectionIncomingCellEvent {
        self.selectionHandler?.selectionCellEvent(id) ?? .unknown
    }
    
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorSelectionIncomingCellEvent, Never> {
        self.selectionHandler?.selectionCellEventPublisher(id) ?? .empty()
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
