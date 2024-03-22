import SecureService

final class SeedService: SeedServiceProtocol {
    
    @Injected(\.keychainStore)
    private var keychainStore: KeychainStoreProtocol
    
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
