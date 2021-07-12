import Foundation
import Combine
import os


final class BlockActiveRecord {
    private weak var _container: BlockContainer?
    private var _nestedModel: BlockModel
    
    init(container: BlockContainer, chosenBlock: BlockModel) {
        self._container = container
        self._nestedModel = chosenBlock
    }
    
    required init(_ chosen: BlockActiveRecord) {
        self._container = chosen._container
        self._nestedModel = chosen._nestedModel
    }
}

extension BlockActiveRecord: ObservableObject, BlockActiveRecordProtocol {
    var container: BlockContainerModelProtocol? {
        self._container
    }
    
    var blockModel: BlockModelProtocol {
        self._nestedModel
    }
    
    static let defaultIndentationLevel = -1
    var indentationLevel: Int {
        if self.isRoot {
            return Self.defaultIndentationLevel
        }

        guard let parentId = self._nestedModel.parent else { return Self.defaultIndentationLevel }
        guard let parent = self._container?._choose(by: parentId) else { return Self.defaultIndentationLevel }
        switch self._nestedModel.kind {
        case .meta: return parent.indentationLevel
        case .block: return parent.indentationLevel + 1
        }
    }
    
    var isRoot: Bool {
        self._nestedModel.parent == nil
    }
    
    func findParent() -> Self? {
        if self.isRoot {
            return nil
        }

        guard let parentId = self._nestedModel.parent else { return nil }
        guard let parent = self._container?._choose(by: parentId) else { return nil }
        return Self.init(parent)
    }
    
    func findRoot() -> Self? {
        sequence(first: self, next: {$0.findParent()}).reversed().first.flatMap(Self.init)
    }
    
    func childrenIds() -> [BlockId] {
        self.blockModel.information.childrenIds
    }
    
    func findChild(by id: BlockId) -> Self? {
        guard let child = self._container?._choose(by: id) else { return nil }
        return Self.init(child)
    }
    
    var isFirstResponder: Bool {
        get {
            container?.userSession.firstResponder?.information.id == _nestedModel.information.id
        }
        set {
            self.container?.userSession.firstResponder = _nestedModel
        }
    }
    
    func unsetFirstResponder() {
        if self.isFirstResponder {
            self.container?.userSession.firstResponder = nil
        }
    }
    
    var isToggled: Bool {
        get {
            container?.userSession.toggles[_nestedModel.information.id] ?? false
        }
    }
    
    func toggle() {
        let newValue = !isToggled
        container?.userSession.toggles[_nestedModel.information.id] = newValue
    }
    
    var focusAt: BlockFocusPosition? {
        get {
            guard container?.userSession.firstResponder?.information.id == _nestedModel.information.id else { return nil }
            return container?.userSession.focus
        }
        set {
            guard container?.userSession.firstResponder?.information.id == _nestedModel.information.id else { return }
            if let value = newValue {
                container?.userSession.focus = value
            }
            else {
                container?.userSession.focus = nil
            }
        }
    }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.blockModel.didChangePublisher() }
    func didChange() { self.blockModel.didChange() }
    
    func didChangeInformationPublisher() -> AnyPublisher<BlockInformation, Never> { self.blockModel.didChangeInformationPublisher() }
}
