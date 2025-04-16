import Foundation
import AnytypeCore

public protocol EncryptionKeyServiceSharedProtocol: AnyObject {
    func obtainKeyById(_ id: String) throws -> String?
    func saveKey(_ key: String, id: String) throws
}


final class EncryptionKeyServiceShared: EncryptionKeyServiceSharedProtocol {
    
    let userDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    
    var dict: [String: Data] = [:]
    
    func obtainKeyById(_ id: String) throws -> String? {
        userDefaults?.string(forKey: id)
    }
    
    func saveKey(_ key: String, id: String) throws {
        userDefaults?.set(key, forKey: id)
    }
}
