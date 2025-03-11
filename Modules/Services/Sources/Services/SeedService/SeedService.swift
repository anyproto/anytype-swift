import SecureService

public protocol SeedServiceProtocol: AnyObject, Sendable {
    func obtainSeed() throws -> String
    func saveSeed(_ seed: String) throws
    func removeSeed() throws
}

final class SeedService: SeedServiceProtocol {
    
    private let keychainStore: any KeychainStoreProtocol = Container.shared.keychainStore()
    
    func removeSeed() throws {
        try keychainStore.removeItem(queryable: query())
        try keychainStore.removeItem(queryable: queryWithNoGroup())
    }
    
    func obtainSeed() throws -> String {
        do {
            return try keychainStore.retreiveItem(queryable: query())
        } catch KeychainError.itemNotFound {
            return try migrateToAppGroupKeychain()
        }
    }
    
    func saveSeed(_ seed: String) throws {
        let seed = seed.trimmingCharacters(in: .whitespacesAndNewlines)
        try keychainStore.storeItem(item: seed, queryable: query())
    }
    
    private func query() -> GenericPasswordQueryable {
        GenericPasswordQueryable(
            account: Constants.secAttrAccount,
            service: Constants.secAttrService,
            accessGroup: Constants.secAttrAccessGroup
        )
    }
    
    private func queryWithNoGroup() -> GenericPasswordQueryable {
        GenericPasswordQueryable(
            account: Constants.secAttrAccount,
            service: Constants.secAttrService
        )
    }
    
    private func migrateToAppGroupKeychain() throws -> String {
        let seed = try keychainStore.retreiveItem(queryable: queryWithNoGroup())
        try saveSeed(seed)
        return seed
    }
}

private extension SeedService {
    enum Constants {
        static let secAttrService = "com.anytype.seedPhrase"
        static let secAttrAccount = "AnytypeSeedPhrase"
        static let secAttrAccessGroup = "group.io.anytype.app"
    }
}
