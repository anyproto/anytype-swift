import Services
import AnytypeCore

protocol GlobalSearchSavedStatesServiceProtocol: AnyObject {
    func storeState(_ state: GlobalSearchState, spaceId: String)
    func restoreState(for spaceId: String) -> GlobalSearchState?
    func clear()
}

final class GlobalSearchSavedStatesService: GlobalSearchSavedStatesServiceProtocol {
        
    // [SpaceId : GlobalSearchState]
    @UserDefault("UserData.GlobalSearchSavedStates", defaultValue: [:])
    private var spacesSearchStates: [String: GlobalSearchState]
    
    // MARK: - GlobalSearchSavedStatesServiceProtocol
    
    func restoreState(for spaceId: String) -> GlobalSearchState? {
        spacesSearchStates[spaceId]
    }
    
    func storeState(_ state: GlobalSearchState, spaceId: String) {
        spacesSearchStates[spaceId] = state
    }
    
    func clear() {
        spacesSearchStates.removeAll()
    }
}
