import Security
import LocalAuthentication
import Foundation

public protocol KeychainStoreProtocol: AnyObject, Sendable {
    func storeItem(item: String, queryable: SecureStoreQueryable) throws
    func retreiveItem(queryable: SecureStoreQueryable) throws -> String
    func contains(queryable: SecureStoreQueryable) -> Bool
    func removeItem(queryable: SecureStoreQueryable) throws
}

/// Wrapper for keychain store
public final class KeychainStore: KeychainStoreProtocol {
    
    // MARK: - Public methods
    public init() {}
    
    /// Add item (password, key, certificate, etc.) to keychain
    ///
    /// - Parameters:
    ///   - item: Item to store in keychain
    public func storeItem(item: String, queryable: SecureStoreQueryable) throws {
        guard let dataItem = item.data(using: .utf8) else {
            throw KeychainError.stringItem2DataConversionError
        }
        
        // try to update item in keychain
        let attributes: [String: Any] = [
            (kSecValueData as String): dataItem
        ]
        
        var query = queryable.query

        var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        // If item wasn't found in keychain, than try to add it to keychain
        if status != errSecSuccess {
            query[String(kSecValueData)] = dataItem
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        if status != errSecSuccess {
            throw KeychainError.keychainError(status: status)
        }
    }
    
    /// Obtain item from keychain
    ///
    /// - Returns: Stored item from keychain
    public func retreiveItem(queryable: SecureStoreQueryable) throws -> String {
        var query = queryable.query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        
        var item: CFTypeRef?
        
        // try to find item in keychain
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        var currentToken: String = ""
        
        if status == errSecSuccess {
            guard
                let existingItem = item as? [String: Any],
                let savedItemData = existingItem[kSecValueData as String] as? Data,
                let itemToken = String(data: savedItemData, encoding: .utf8)
                else {
                    throw KeychainError.data2StringItemConversionError
            }
            currentToken = itemToken
        } else {
            throw KeychainError.keychainError(status: status)
        }
        return currentToken
    }
    
    /// Obtain item from keychain
    ///
    /// - Returns: Stored item from keychain
    public func contains(queryable: SecureStoreQueryable) -> Bool {
        var query = queryable.query
        // specify kSecUseAuthenticationUIFail so that the error
        // errSecInteractionNotAllowed will be returned if an item needs
        // to authenticate with UI and the authentication UI will not be presented.
        let context = LAContext()
        context.interactionNotAllowed = true
        query[String(kSecUseAuthenticationContext)] = context
        
        var item: CFTypeRef?
        
        // try to find item in keychain
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        return status == errSecInteractionNotAllowed || status == errSecSuccess
    }
    
    /// Remove item from keychain
    public func removeItem(queryable: SecureStoreQueryable) throws {
        let query = queryable.query
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.keychainError(status: status)
        }
    }
    
}
