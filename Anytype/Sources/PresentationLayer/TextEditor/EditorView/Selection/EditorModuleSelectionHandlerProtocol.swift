import BlocksModels
import Combine

protocol EditorModuleSelectionHandlerProtocol: AnyObject {    
    var selectionEnabled: Bool { get set }
    var list: [BlockId] { get }
    
    func deselect(ids: [BlockId: BlockContentType])
    func select(ids: [BlockId: BlockContentType])
    
    func clear()
    
    func selectionEventPublisher() -> AnyPublisher<EditorSelectionIncomingEvent, Never>

    func set(selected: Bool, id: BlockId, type: BlockContentType)
    func selected(id: BlockId) -> Bool

    func selectionCellEvent(_ id: BlockId) -> EditorSelectionIncomingCellEvent
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorSelectionIncomingCellEvent, Never>
}
