import Foundation
import AnytypeCore

public class UserSession {
    public static var shared = UserSession()
    
    public private(set) var focus = AtomicProperty<BlockFocusPosition?>(nil)
    public private(set) var toggles = SynchronizedDictionary<BlockId, Bool>()
    
    public private(set) var firstResponderId = AtomicProperty<BlockId?>(nil)
    public func resignFirstResponder(blockId: BlockId) {
        if blockId == firstResponderId.value {
            firstResponderId.value = nil
        }
    }
}

public extension UserSession {
    func isToggled(blockId: BlockId) -> Bool {
        toggles[blockId] ?? false
    }
}
