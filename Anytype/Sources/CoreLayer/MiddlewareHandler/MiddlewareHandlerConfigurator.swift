import Foundation
import Logger
import ProtobufMessages
import AnytypeCore

final class MiddlewareHandlerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        InvocationSettings.handler = invocationHandler
        
        #if DEBUG
            enableRemoteLogger()
        #else
            tuneRemoteLogger()
        #endif
    }
    
    private func enableRemoteLogger() {
        invocationHandler.enableLogger = true
        EventLogger.setupLgger()
    }
    
    private func disableRemoteLogger() {
        EventLogger.disableRemoteLogger()
    }
    
    private func tuneRemoteLogger() {
        if FeatureFlags.remoteLoggingForAnytype {
            enableRemoteLogger()
        } else {
            disableRemoteLogger()
        }
    }
}
