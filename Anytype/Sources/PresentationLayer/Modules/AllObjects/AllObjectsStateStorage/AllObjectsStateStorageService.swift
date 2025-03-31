import AnytypeCore

protocol AllObjectsStateStorageServiceProtocol: AnyObject {
    func storeSort(_ sort: ObjectSort, spaceId: String)
    func restoreSort(for spaceId: String) -> ObjectSort?
    func clear()
}

final class AllObjectsStateStorageService: AllObjectsStateStorageServiceProtocol {
        
    // [SpaceId : ObjectSort]
    @UserDefault("UserData.AllContentStateStorage", defaultValue: [:])
    private var spacesSorts: [String: ObjectSort]
    
    // MARK: - AllContentSavedStatesServiceProtocol
    
    func storeSort(_ sort: ObjectSort, spaceId: String) {
        spacesSorts[spaceId] = sort
    }
    
    func restoreSort(for spaceId: String) -> ObjectSort? {
        spacesSorts[spaceId]
    }
    
    func clear() {
        spacesSorts.removeAll()
    }
}
