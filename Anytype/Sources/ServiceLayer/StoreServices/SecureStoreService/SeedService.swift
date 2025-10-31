import SecureService
import Security

final class SeedService: SeedServiceProtocol {

    @Injected(\.keychainStore)
    private var keychainStore: any KeychainStoreProtocol

    func removeSeed() throws {
        try keychainStore.removeItem(queryable: query())
    }

    func obtainSeed() throws -> String {
        do {
            return try keychainStore.retreiveItem(queryable: query())
        } catch let KeychainError.keychainError(status) where status == errSecItemNotFound {
            return try migrateFromOldAccessibility()
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
            attrAccessible: .afterFirstUnlockThisDeviceOnly
        )
    }

    private func migrateFromOldAccessibility() throws -> String {
        let oldQuery = GenericPasswordQueryable(
            account: Constants.secAttrAccount,
            service: Constants.secAttrService,
            attrAccessible: .whenUnlockedThisDeviceOnly
        )

        let seed = try keychainStore.retreiveItem(queryable: oldQuery)

        let searchQuery = oldQuery.query
        let updateAttributes: [String: Any] = [
            String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemUpdate(searchQuery as CFDictionary, updateAttributes as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.keychainError(status: status)
        }

        return seed
    }
}

private extension SeedService {
    enum Constants {
        static let secAttrService = "com.anytype.seedPhrase"
        static let secAttrAccount = "AnytypeSeedPhrase"
    }
}
