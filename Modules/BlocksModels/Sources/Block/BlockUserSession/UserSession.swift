import Foundation
import AnytypeCore

public class UserSession {
    public static var shared = UserSession()
    
    public var focus = AtomicProperty<BlockFocusPosition?>(nil)
    public var firstResponderId = AtomicProperty<BlockId?>(nil)
    public var toggles = SynchronizedDictionary<BlockId, Bool>()
}

public extension UserSession {
    func isToggled(blockId: BlockId) -> Bool {
        toggles[blockId] ?? false
    }
}
