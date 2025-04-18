import Foundation
import Logger
import ProtobufMessages
import AnytypeCore

final class MiddlewareHandlerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        InvocationSettings.handler = invocationHandler
        
        if FeatureFlags.logMiddlewareRequests {
            enableRemoteLogger()
        } else {
            disableRemoteLogger()
        }
    }
    
    private func enableRemoteLogger() {
        invocationHandler.enableLogger = true
        if FeatureFlags.networkHTTPSRequestsLogger {
            EventLogger.setupLgger()
        }
    }
    
    private func disableRemoteLogger() {
        EventLogger.disableRemoteLogger()
    }
}
