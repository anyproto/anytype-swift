import Foundation
import AnytypeCore

public class UserSession {
    public static var shared = UserSession()
    
    public private(set) var toggles = SynchronizedDictionary<BlockId, Bool>()
}

public extension UserSession {
    func isToggled(blockId: BlockId) -> Bool {
        toggles[blockId] ?? false
    }
}
