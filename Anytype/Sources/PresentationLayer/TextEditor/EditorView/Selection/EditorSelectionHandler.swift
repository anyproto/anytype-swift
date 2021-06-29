import Foundation
import Combine
import BlocksModels


final class EditorSelectionHandler {
    typealias SelectionEvent = EditorSelectionIncomingEvent
    /// Publishers
    private var subscription: AnyCancellable?
    private var storageEventsSubject: PassthroughSubject<SelectionEvent, Never> = .init()
    private var storageEventsPublisher: AnyPublisher<SelectionEvent, Never> = .empty()
    private lazy var turnIntoOptionsStorage = TurnIntoSelectionStorage()
    /// Storage
    private var storage: EditorSelectionHandlerStorage = .init() {
        didSet {
            self.storageDidChangeSubject.send(self.storage)
            self.handle(self.storage)
        }
    }
    
    private var storageDidChangeSubject: PassthroughSubject<EditorSelectionHandlerStorage, Never> = .init()
    private var storageDidChangePublisher: AnyPublisher<EditorSelectionHandlerStorage, Never> = .empty()
    
    /// Updates
    private func storageEvent(from storage: EditorSelectionHandlerStorage) -> SelectionEvent {
        if !storage.selectionEnabled() {
            return .selectionDisabled
        }
        if storage.isEmpty() {
            return .selectionEnabled
        }

        let typesArray = self.turnIntoOptionsStorage.turnIntoOptions()
        return .selectionEnabled(.nonEmpty(.init(storage.count()),
                                           turnIntoStyles: typesArray))
    }
    
    private func handle(_ storageUpdate: EditorSelectionHandlerStorage) {
        self.storageEventsSubject.send(self.storageEvent(from: storageUpdate))
    }
    
    /// Setup
    func setup() {
        self.storageDidChangePublisher = self.storageDidChangeSubject.eraseToAnyPublisher()
        self.storageEventsPublisher = self.storageEventsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init() {
        self.setup()
    }
}

extension EditorSelectionHandler: EditorModuleSelectionHandlerProtocol {
    var selectionEnabled: Bool {
        get {
            storage.selectionEnabled()
        }
        set {
            if storage.selectionEnabled() != newValue {
                storage.toggleSelectionEnabled()
            }
            if !selectionEnabled {
                turnIntoOptionsStorage.clear()
            }
        }
    }
    
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    func deselect(ids: [BlockId: BlockContentType]) {
        guard selectionEnabled else { return }
        ids.values.forEach { self.turnIntoOptionsStorage.deselectBlockType(type: $0) }
        self.storage.remove(ids: Set(ids.keys))
    }
        
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    /// Is it better to use `add(ids:)` here?
    ///
    func select(ids: [BlockId: BlockContentType]) {
        guard selectionEnabled else { return }
        ids.values.forEach { self.turnIntoOptionsStorage.selectBlockType(type: $0) }
        self.storage.set(ids: Set(ids.keys))
    }
    
    var list: [BlockId] {
        storage.listSelectedIds()
    }
    
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    /// But, we still `CAN` clear storage without checking if selection is enabled.
    ///
    func clear() {
        self.turnIntoOptionsStorage.clear()
        self.storage.clear()
    }
    
    func selectionEventPublisher() -> AnyPublisher<SelectionEvent, Never> {
        self.storageEventsPublisher
    }
    
    /// We should fire events only if selection is enabled.
    /// Otherwise, we can't remove or selected ids.
    ///
    func set(selected: Bool, id: BlockId, type: BlockContentType) {
        guard selectionEnabled else { return }
        if selected {
            self.turnIntoOptionsStorage.selectBlockType(type: type)
        } else {
            self.turnIntoOptionsStorage.deselectBlockType(type: type)
        }
        let contains = self.storage.contains(id: id)
        if contains != selected {
            self.storage.toggle(id: id)
        }
    }
    
    func selected(id: BlockId) -> Bool {
        self.storage.contains(id: id)
    }
    
    func selectionCellEvent(_ id: BlockId) -> EditorSelectionIncomingCellEvent {
        let isSelected = self.selected(id: id)
        return .payload(.init(selectionEnabled: selectionEnabled, isSelected: isSelected))
    }
    
    func selectionCellEventPublisher(_ id: BlockId) -> AnyPublisher<EditorSelectionIncomingCellEvent, Never> {
        self.storageDidChangePublisher.map({ value in
            .payload(.init(selectionEnabled: value.selectionEnabled(), isSelected: value.contains(id: id)))
        }).removeDuplicates().eraseToAnyPublisher()
    }
}
