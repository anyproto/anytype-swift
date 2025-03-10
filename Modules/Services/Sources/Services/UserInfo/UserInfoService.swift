import Foundation
import AnytypeCore

public protocol UserInfoServiceProtocol: AnyObject, Sendable {
    func getUserId() -> String
    func setUserId(_ id: String)
    func clearUserId()
    
    func getAnalyticsId() -> String?
    func setAnalyticsId(_ id: String)
}

final class UserInfoService: UserInfoServiceProtocol, @unchecked Sendable {
    
    private let userDefaults = UserDefaults(suiteName: "group.io.anytype.app")
    
    // MARK: - UserId
    
    @UserDefault(Constants.userIdKey, defaultValue: "")
    private var userId: String
    
    func getUserId() -> String {
        userDefaults?.string(forKey: Constants.userIdKey) ?? userId
    }
    
    func setUserId(_ id: String) {
        userDefaults?.set(id, forKey: Constants.userIdKey)
    }
    
    func clearUserId() {
        userId = ""
        userDefaults?.set("", forKey: Constants.userIdKey)
    }
    
    // MARK: - AnalyticsId
    
    @UserDefault(Constants.analyticsIdKey, defaultValue: nil)
    var analyticsId: String?
    
    func getAnalyticsId() -> String? {
        analyticsId
    }
    
    func setAnalyticsId(_ id: String) {
        analyticsId = id
    }
}


extension UserInfoService {
    enum Constants {
        static let userIdKey = "userId"
        static let analyticsIdKey = "analyticsId"
    }
}
