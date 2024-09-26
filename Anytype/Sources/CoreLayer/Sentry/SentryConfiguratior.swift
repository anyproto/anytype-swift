import Foundation
import Sentry
import Logger
import AnytypeCore

final class SentryConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        
        guard let env = Bundle.main.object(forInfoDictionaryKey: Constant.env) as? String,
              env.isNotEmpty else { return }
        
        guard let dsn = Bundle.main.object(forInfoDictionaryKey: Constant.dsn) as? String,
              dsn.isNotEmpty else { return }
        
        SentrySDK.start { options in
            options.dsn = dsn
            options.enableCaptureFailedRequests = false
            options.enableMetricKit = true
            options.swiftAsyncStacktraces = true
            options.enableAppHangTracking = false
            
            #if DEBUG
            options.attachViewHierarchy = true
            options.enableTimeToFullDisplayTracing = true
            options.tracesSampleRate = 1.0
            options.sampleRate = 1.0
            #else
            options.tracesSampleRate = 0.5
            options.sampleRate = 0.5
            #endif
            
            options.environment = env
        }
        
        let configProvider = Container.shared.middlewareConfigurationProvider.resolve()
        Task {
            let version = (try? await configProvider.libraryVersion()) ?? "undefined"
            SentrySDK.configureScope { scope in
                scope.setContext(value: ["version" : version], key: "middleware")
                scope.setTag(value: version, key: SentryTagKey.middlewareVersion.rawValue)
                scope.setTag(value: BuildTypeProvider.buidType.rawValue, key: SentryTagKey.buidType.rawValue)
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
