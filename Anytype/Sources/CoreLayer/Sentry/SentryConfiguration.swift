import Foundation
import Sentry
import Logger

final class SentryConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        
        guard let env = Bundle.main.object(forInfoDictionaryKey: Constant.env) as? String,
              env.isNotEmpty else { return }
        
        guard let dsn = Bundle.main.object(forInfoDictionaryKey: Constant.dsn) as? String,
              dsn.isNotEmpty else { return }
        
        SentrySDK.start { options in
            options.dsn = dsn
            options.tracesSampleRate = 1.0
            options.enableCaptureFailedRequests = false
            options.enableMetricKit = true
            
            options.environment = env
        }
        
        AssertionLogger.shared.handler = SentryNonFatalLogger()
    }
}

private extension SentryConfigurator {
    enum Constant {
        static let env = "SentryEnv"
        static let dsn = "SentryDSN"
    }
}
