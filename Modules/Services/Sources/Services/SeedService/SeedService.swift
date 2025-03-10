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
    }
    
    func obtainSeed() throws -> String {
        try keychainStore.retreiveItem(queryable: query())
    }
    
    func saveSeed(_ seed: String) throws {
        let seed = seed.trimmingCharacters(in: .whitespacesAndNewlines)
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
