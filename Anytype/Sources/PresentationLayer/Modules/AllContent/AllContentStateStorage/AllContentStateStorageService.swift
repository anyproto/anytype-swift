import AnytypeCore

protocol AllContentStateStorageServiceProtocol: AnyObject {
    func storeSort(_ sort: AllContentSort, spaceId: String)
    func restoreSort(for spaceId: String) -> AllContentSort?
    func clear()
}

final class AllContentStateStorageService: AllContentStateStorageServiceProtocol {
        
    // [SpaceId : AllContentSort]
    @UserDefault("UserData.AllContentStateStorage", defaultValue: [:])
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
