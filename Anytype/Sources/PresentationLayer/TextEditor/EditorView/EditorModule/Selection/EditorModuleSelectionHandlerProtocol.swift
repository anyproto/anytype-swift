import BlocksModels
import Combine

protocol EditorModuleSelectionHandlerProtocol: EditorModuleSelectionHandlerListProtocol, EditorModuleSelectionHandlerCellProtocol {}


protocol EditorModuleSelectionHandlerListProtocol {
    typealias SelectionEvent = EditorSelectionIncomingEvent
    typealias SelectionCellEvent = EditorSelectionIncomingCellEvent
    func selectionEnabled() -> Bool
    func set(selectionEnabled: Bool)
    
    func deselect(ids: [BlockId: BlockContentType])
    func select(ids: [BlockId: BlockContentType])
    
    func list() -> [BlockId]
    func clear()
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never>
}

protocol EditorModuleSelectionHandlerCellProtocol: AnyObject {
    func set(selected: Bool, id: BlockId, type: BlockContentType)
    func selected(id: BlockId) -> Bool

    func selectionCellEvent(_ id: BlockId) -> EditorSelectionIncomingCellEvent
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorSelectionIncomingCellEvent, Never>
}
