import Foundation
import Sentry
import Logger
import AnytypeCore
import Factory

enum AppSessionError: Error {
    case sessionWithoutFinish
}

final class SentryConfigurator: AppConfiguratorProtocol {
    
    @Injected(\.appSessionTracker)
    private var appSessionTracker: any AppSessionTrackerProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    private enum Constants {
        static let fileName = "stdout.txt"
        static let oldSessionFileName = "stdout-old.txt"
        static let contentType = "text/plain"
    }
    
    func configure() {
        
        guard let env = Bundle.main.object(forInfoDictionaryKey: Constant.env) as? String,
              env.isNotEmpty else { return }
        
        guard let dsn = Bundle.main.object(forInfoDictionaryKey: Constant.dsn) as? String,
              dsn.isNotEmpty else { return }
        let report = appSessionTracker.oldSessionReport
        
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
                        
            options.onCrashedLastRun = { event in
                guard let report else { return }
                
                let attachment = Attachment(
                    path: report.reportPath,
                    filename: Constants.oldSessionFileName,
                    contentType: Constants.contentType
                )
                
                SentrySDK.capture(event: event) { scope in
                    scope.addAttachment(attachment)
                }
            }
        }
        
        // Restore userId from old session
        let user = User()
        user.userId = userDefaults.analyticsId
        SentrySDK.setUser(user)
        
        let configProvider = Container.shared.middlewareConfigurationProvider.resolve()
        Task {
            let version = (try? await configProvider.libraryVersion()) ?? "undefined"
            
            let attachment = Attachment(
                path: appSessionTracker.currentSessionReportPath,
                filename: Constants.fileName,
                contentType: Constants.contentType
            )
            
            SentrySDK.configureScope { scope in
                scope.setContext(value: ["version" : version], key: "middleware")
                scope.setTag(value: version, key: SentryTagKey.middlewareVersion.rawValue)
                scope.setTag(value: BuildTypeProvider.buidType.rawValue, key: SentryTagKey.buidType.rawValue)
                
                #if !RELEASE_ANYTYPE
                scope.addAttachment(attachment)
                #endif
            }
            
            #if !RELEASE_ANYTYPE
            logOldAppUnhandledSession()
            #endif
        }
        
        AssertionLogger.shared.addHandler(SentryNonFatalLogger())
    }
    
    private func logOldAppUnhandledSession() {
        if let report = appSessionTracker.oldSessionReport,
            !report.sessionFinished,
            !SentrySDK.crashedLastRun {

            let attachment = Attachment(
                path: report.reportPath,
                filename: Constants.oldSessionFileName,
                contentType: Constants.contentType
            )
            
            SentrySDK.capture(error: AppSessionError.sessionWithoutFinish) { scope in
                scope.addAttachment(attachment)
                scope.setLevel(.fatal)
            }
        }
    }
}

private extension SentryConfigurator {
    enum Constant {
        static let env = "SentryEnv"
        static let dsn = "SentryDSN"
    }
}
