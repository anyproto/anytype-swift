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
            options.swiftAsyncStacktraces = true
            options.enableAppHangTracking = false
            
            #if DEBUG
            options.attachViewHierarchy = true
            options.enableTimeToFullDisplay = true
            #endif
            
            options.environment = env
        }
        
        let configProvider = ServiceLocator.shared.middlewareConfigurationProvider()
        Task {
            let version = (try? await configProvider.libraryVersion()) ?? "undefined"
            SentrySDK.configureScope { scope in
                scope.setContext(value: ["version" : version], key: "middleware")
                scope.setTag(value: version, key: "middleware.version")
            }
        }
        
        AssertionLogger.shared.addHandler(SentryNonFatalLogger())
    }
}

private extension SentryConfigurator {
    enum Constant {
        static let env = "SentryEnv"
        static let dsn = "SentryDSN"
    }
}
