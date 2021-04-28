import Foundation
import Combine
import os


class BlockUserSession: ObservableObject {
    private var _firstResponder: String?
    private var _focusAt: Position?
    private var toggleStorage: [String: Bool] = [:]
}

extension BlockUserSession: BlockUserSessionModelProtocol {
    func isToggled(by id: BlockId) -> Bool { self.toggleStorage[id, default: false] }
    func isFirstResponder(by id: BlockId) -> Bool { self._firstResponder == id }
    func firstResponder() -> BlockId? { self._firstResponder }
    func focusAt() -> Position? { self._focusAt }
    func setToggled(by id: BlockId, value: Bool) { self.toggleStorage[id] = value }
    func setFirstResponder(by id: BlockId) { self._firstResponder = id }
    func setFocusAt(position: Position) { self._focusAt = position }
    
    func unsetFirstResponder() { self._firstResponder = nil }
    func unsetFocusAt() { self._focusAt = nil }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.objectWillChange.eraseToAnyPublisher() }
    func didChange() { self.objectWillChange.send() }
}
