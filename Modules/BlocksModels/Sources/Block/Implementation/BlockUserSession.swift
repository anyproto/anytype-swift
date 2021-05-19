import Foundation
import Combine
import os


class BlockUserSession: ObservableObject {
    private var _firstResponderBlockModel: BlockModelProtocol?
    private var _firstResponder: String?
    private var _focusAt: Position?
    private var toggleStorage: [String: Bool] = [:]
}

extension BlockUserSession: BlockUserSessionModelProtocol {
    func isToggled(by id: BlockId) -> Bool { self.toggleStorage[id, default: false] }
    func isFirstResponder(by id: BlockId) -> Bool { firstResponderId() == id }
    func firstResponderId() -> BlockId? { _firstResponder ?? _firstResponderBlockModel?.information.id }
    func firstResponder() -> BlockModelProtocol? { _firstResponderBlockModel }

    func focusAt() -> Position? { self._focusAt }
    func setToggled(by id: BlockId, value: Bool) { self.toggleStorage[id] = value }

    func setFirstResponder(with blockModel: BlockModelProtocol) {
        _firstResponder = blockModel.information.id
        _firstResponderBlockModel = blockModel
    }

    func setFocusAt(position: Position) { self._focusAt = position }
    
    func unsetFirstResponder() { self._firstResponder = nil }
    func unsetFocusAt() { self._focusAt = nil }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.objectWillChange.eraseToAnyPublisher() }
    func didChange() { self.objectWillChange.send() }
}
