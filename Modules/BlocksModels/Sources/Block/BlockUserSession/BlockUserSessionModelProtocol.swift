import Combine

public protocol BlockUserSessionModelProtocol {
    /// Get toggled state for block
    ///
    /// - Parameters:
    ///   - id: Block id to get state
    func isToggled(by id: BlockId) -> Bool
    func isFirstResponder(by id: BlockId) -> Bool
    func firstResponderId() -> BlockId?
    func firstResponder() -> BlockModelProtocol?
    func focusAt() -> BlockFocusPosition?
    /// Set toggled state for block
    ///
    /// - Parameters:
    ///   - id: Block id to change state
    func setToggled(by id: BlockId, value: Bool)
    func setFirstResponder(with blockModel: BlockModelProtocol)
    func setFocusAt(position: BlockFocusPosition)
    
    func unsetFirstResponder()
    func unsetFocusAt()
    
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
}
