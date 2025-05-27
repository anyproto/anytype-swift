import AnytypeCore
import Foundation

public protocol BasicUserInfoStorageProtocol: AnyObject, Sendable {
    var usersId: String { get set }
    var analyticsId: String? { get set }
    
    func cleanUserIdAfterLogout()
}

final class BasicUserInfoStorage: BasicUserInfoStorageProtocol, @unchecked Sendable {
    
    @UserDefaultByAppGroup("userId", defaultValue: "")
    var usersId: String
    
    @UserDefaultByAppGroup("analyticsId", defaultValue: nil)
    var analyticsId: String?
    
    func cleanUserIdAfterLogout() {
        usersId = ""
    }
}
