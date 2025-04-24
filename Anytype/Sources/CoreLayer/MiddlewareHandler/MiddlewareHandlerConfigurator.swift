import Foundation
import Logger
import ProtobufMessages
import AnytypeCore

final class MiddlewareHandlerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        InvocationSettings.handler = invocationHandler
        
        if FeatureFlags.logMiddlewareRequests {
            invocationHandler.enableLogger = true
            if FeatureFlags.networkHTTPSRequestsLogger {
                EventLogger.setupLgger()
            }
        } else {
            EventLogger.disableRemoteLogger()
        }
    }
}
