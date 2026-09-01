import Foundation
import AnytypeCore

protocol UnifiedSearchStateServiceProtocol: AnyObject {
    func storeState(_ state: UnifiedSearchState)
    func restoreState() -> UnifiedSearchState?
    func clear()
}

final class UnifiedSearchStateService: UnifiedSearchStateServiceProtocol {

    private struct SavedState: Codable {
        let state: UnifiedSearchState
        let lastUsed: Date
    }

    // Search state resets to defaults after 5 idle minutes
    private static let idleResetInterval: TimeInterval = 300

    // One vault-level record - the scope is itself a token, so there is no per-space keying
    @UserDefault("UserData.UnifiedSearchSavedState", defaultValue: nil)
    private var savedState: SavedState?

    // MARK: - UnifiedSearchStateServiceProtocol

    func restoreState() -> UnifiedSearchState? {
        guard let savedState, Date.now.timeIntervalSince(savedState.lastUsed) < Self.idleResetInterval else {
            return nil
        }
        return savedState.state
    }

    func storeState(_ state: UnifiedSearchState) {
        savedState = SavedState(state: state, lastUsed: .now)
    }

    func clear() {
        savedState = nil
    }
}
