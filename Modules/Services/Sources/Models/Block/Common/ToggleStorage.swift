import Foundation
import AnytypeCore

public final class ToggleStorage: @unchecked Sendable {
    public static let shared = ToggleStorage()
    
    private var toggles = SynchronizedDictionary<String, Bool>()

    public func isToggled(blockId: String) -> Bool {
        toggles[blockId] ?? false
    }
    
    public func toggle(blockId: String) {
        toggles[blockId] = !isToggled(blockId: blockId)
    }
}
