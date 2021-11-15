private extension SeedService {
    enum Constants {
        static let serviceName = "com.AnyType.seed"
        static let defaultName = "AnyTypeSeed"
    }
}

final class SeedService: SeedServiceProtocol {
    private let keychainStore: KeychainStoreProtocol
    init(keychainStore: KeychainStoreProtocol) {
        self.keychainStore = keychainStore
    }
    
    func removeSeed() throws {
        try keychainStore.removeItem(queryable: query())
    }
    
    func obtainSeed() throws -> String {
        try keychainStore.retreiveItem(queryable: query())
    }
    
    func saveSeed(_ seed: String) throws {
        try keychainStore.storeItem(item: seed, queryable: query())
    }
    
    private func query() -> GenericPasswordQueryable {
        GenericPasswordQueryable(
            account: Constants.defaultName,
            service: Constants.serviceName,
            keyChainPassword: .none
        )
    }
}
