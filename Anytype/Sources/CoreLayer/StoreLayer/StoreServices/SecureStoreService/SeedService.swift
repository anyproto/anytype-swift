
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
            account: Constants.secAttrAccount,
            service: Constants.secAttrService
        )
    }
}

private extension SeedService {
    enum Constants {
        static let secAttrService = "com.anytype.seedPhrase"
        static let secAttrAccount = "AnytypeSeedPhrase"
    }
}
