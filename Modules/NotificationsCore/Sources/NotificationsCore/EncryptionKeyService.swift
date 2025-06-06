import Foundation
import AnytypeCore
import SecureService

public protocol EncryptionKeyServiceProtocol: AnyObject, Sendable {
    func obtainKeyById(_ keyId: String) throws -> String
    func saveKey(_ key: String, keyId: String) throws
}

public final class EncryptionKeyService: EncryptionKeyServiceProtocol {
    
    private let keychainStore: any KeychainStoreProtocol = KeychainStore()
    
    public init() {}
    
    public func obtainKeyById(_ keyId: String) throws -> String {
        try keychainStore.retreiveItem(queryable: query(with: keyId))
    }
    
    public func saveKey(_ key: String, keyId: String) throws {
        try keychainStore.storeItem(item: key, queryable: query(with: keyId))
    }
    
    private func query(with keyId: String) -> GenericPasswordQueryable {
        GenericPasswordQueryable(
            account: keyId,
            service: Constants.secAttrService,
            accessGroup: TargetsConstants.appGroup,
            attrAccessible: .afterFirstUnlockThisDeviceOnly
        )
    }
}

private extension EncryptionKeyService {
    enum Constants {
        static let secAttrService = "com.anytype.encryptionKey"
    }
}
