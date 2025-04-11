import Foundation

public protocol EncryptionKeyServiceSharedProtocol {
    func obtainKeyById(_ id: String) throws -> Data?
    func saveKey(_ data: Data, id: String) throws
}


final class EncryptionKeyServiceShared: EncryptionKeyServiceSharedProtocol {
    
    let userDefaults = UserDefaults(suiteName: "group.io.anytype.app")
    
    var dict: [String: Data] = [:]
    
    func obtainKeyById(_ id: String) throws -> Data? {
        userDefaults?.data(forKey: id)
    }
    
    func saveKey(_ data: Data, id: String) throws {
        userDefaults?.set(data, forKey: id)
    }
}
