private enum SeedServiceConstants {
    static let serviceName = "com.AnyType.seed"
    static let defaultName = "defaultAnyTypeSeed"
}

/// Keychain store serivce
final class SeedService: SeedServiceProtocol {
    private let keychainStore: KeychainStoreProtocol
    init(keychainStore: KeychainStoreProtocol) {
        self.keychainStore = keychainStore
    }
    
    func removeSeed(for publicKey: String?, keychainPassword: KeychainPasswordType?) throws {
        let seedQuery = GenericPasswordQueryable(
            account: publicKey ?? SeedServiceConstants.defaultName,
            service: SeedServiceConstants.serviceName,
            keyChainPassword: keychainPassword
        )
        try keychainStore.removeItem(queryable: seedQuery)
    }
    
    func obtainSeed(for name: String?, keychainPassword: KeychainPasswordType?) throws -> String {
        let seedQuery = GenericPasswordQueryable(
            account: name ?? SeedServiceConstants.defaultName,
            service: SeedServiceConstants.serviceName,
            keyChainPassword: keychainPassword
        )
        let seed = try keychainStore.retreiveItem(queryable: seedQuery)
        return seed
    }
    
    func saveSeedForAccount(name: String?, seed: String, keychainPassword: KeychainPasswordType?) throws {
        let seedQuery = GenericPasswordQueryable(
            account: name ?? SeedServiceConstants.defaultName,
            service: SeedServiceConstants.serviceName,
            keyChainPassword: keychainPassword
        )
        try keychainStore.storeItem(item: seed, queryable: seedQuery)
    }
}
