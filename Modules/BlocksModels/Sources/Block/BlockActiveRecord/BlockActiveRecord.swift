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
    class func create(_ chosen: BlockActiveRecord) -> Self {
        .init(chosen)
    }
}

extension BlockActiveRecord: ObservableObject, BlockActiveRecordModelProtocol {
    var container: BlockContainerModelProtocol? {
        self._container
    }
    
    var blockModel: BlockModelProtocol {
        self._nestedModel
    }
    
    static var defaultIndentationLevel: Int { -1 }
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
            self.container?.userSession.isFirstResponder(by: self._nestedModel.information.id) ?? false
        }
        set {
            self.container?.userSession.setFirstResponder(with: self._nestedModel)
        }
    }
    
    func unsetFirstResponder() {
        if self.isFirstResponder {
            self.container?.userSession.unsetFirstResponder()
        }
    }
    
    var isToggled: Bool {
        get {
            self.container?.userSession.isToggled(by: self._nestedModel.information.id) ?? false
        }
        set {
            self.container?.userSession.setToggled(by: self._nestedModel.information.id, value: newValue)
        }
    }
    
    var focusAt: BlockFocusPosition? {
        get {
            guard self.container?.userSession.firstResponderId() == self._nestedModel.information.id else { return nil }
            return self.container?.userSession.focusAt()
        }
        set {
            guard self.container?.userSession.firstResponderId() == self._nestedModel.information.id else { return }
            if let value = newValue {
                self.container?.userSession.setFocusAt(position: value)
            }
            else {
                self.container?.userSession.unsetFocusAt()
            }
        }
    }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.blockModel.didChangePublisher() }
    func didChange() { self.blockModel.didChange() }
    
    func didChangeInformationPublisher() -> AnyPublisher<BlockInformation.InformationModel, Never> { self.blockModel.didChangeInformationPublisher() }
}
