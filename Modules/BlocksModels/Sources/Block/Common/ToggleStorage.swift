import Foundation
import AnytypeCore

public class ToggleStorage {
    public static let shared = ToggleStorage()
    
    private var toggles = SynchronizedDictionary<BlockId, Bool>()

    public func isToggled(blockId: BlockId) -> Bool {
        toggles[blockId] ?? false
    }
    
    public func toggle(blockId: BlockId) {
        toggles[blockId] = !isToggled(blockId: blockId)
    }
}
