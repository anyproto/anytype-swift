import Foundation
import Sentry

@MainActor
protocol AppErrorLoggerConfigurationProtocol: AnyObject {
    func setUserId(_ userId: String)
}

@MainActor
final class AppErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol {
    
    nonisolated init() {}
    
    // MARK: - AppErrorLoggerConfigurationProtocol
    
    func setUserId(_ userId: String) {
        let user = User()
        user.userId = userId
        SentrySDK.setUser(user)
    }
}
