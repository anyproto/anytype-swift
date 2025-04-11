import SecureService

public protocol EncryptionKeyServiceProtocol {
    func obtainKeyById(_ id: String) throws -> String
    func saveKey(_ key: String, id: String) throws
}


final class EncryptionKeyService: EncryptionKeyServiceProtocol {
    
    @Injected(\.keychainStore)
    private var keychainStore: any KeychainStoreProtocol
    
    
    func obtainKeyById(_ id: String) throws -> String {
        try keychainStore.retreiveItem(queryable: query())
    }
    
    func saveKey(_ key: String, id: String) throws {
        
    }
    
    private func query() -> GenericPasswordQueryable {
        GenericPasswordQueryable(
            account: Constants.secAttrAccount,
            service: Constants.secAttrService
        )
    }
}

private extension EncryptionKeyService {
    enum Constants {
        static let secAttrService = "com.anytype.encryptionKey"
        static let secAttrAccount = "encryptionKey"
    }
}
