import Foundation
import Sentry

protocol AppErrorLoggerConfigurationProtocol: AnyObject {
    func setUserId(_ userId: String)
}

final class AppErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol {
    
    // MARK: - AppErrorLoggerConfigurationProtocol
    
    func setUserId(_ userId: String) {
        let user = User()
        user.userId = userId
        SentrySDK.setUser(user)
    }
}
