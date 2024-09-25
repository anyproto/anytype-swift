import AnytypeCore

protocol AllContentSavedStatesServiceProtocol: AnyObject {
    func storeSort(_ sort: AllContentSort, spaceId: String)
    func restoreSort(for spaceId: String) -> AllContentSort?
    func clear()
}

final class AllContentSavedStatesService: AllContentSavedStatesServiceProtocol {
        
    // [SpaceId : AllContentSort]
    @UserDefault("UserData.AllContentSavedStates", defaultValue: [:])
    private var spacesSorts: [String: AllContentSort]
    
    // MARK: - AllContentSavedStatesServiceProtocol
    
    func storeSort(_ sort: AllContentSort, spaceId: String) {
        spacesSorts[spaceId] = sort
    }
    
    func restoreSort(for spaceId: String) -> AllContentSort? {
        spacesSorts[spaceId]
    }
    
    func clear() {
        spacesSorts.removeAll()
    }
}
