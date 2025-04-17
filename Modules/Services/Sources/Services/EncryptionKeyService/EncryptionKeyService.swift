import Foundation
import AnytypeCore
import SecureService

public protocol EncryptionKeyServiceProtocol: AnyObject, Sendable {
    func obtainKeyById(_ spaceId: String) throws -> String
    func saveKey(_ key: String, spaceId: String) throws
}

final class EncryptionKeyService: EncryptionKeyServiceProtocol {
    
    private let keychainStore: any KeychainStoreProtocol = Container.shared.keychainStore()
    
    func obtainKeyById(_ spaceId: String) throws -> String {
        try keychainStore.retreiveItem(queryable: query(with: spaceId))
    }
    
    func saveKey(_ key: String, spaceId: String) throws {
        try keychainStore.storeItem(item: key, queryable: query(with: spaceId))
    }
    
    private func query(with spaceId: String) -> GenericPasswordQueryable {
        GenericPasswordQueryable(
            account: spaceId,
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
