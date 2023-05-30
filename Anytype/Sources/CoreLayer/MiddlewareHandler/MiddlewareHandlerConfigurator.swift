import Foundation
import Logger
import ProtobufMessages

final class MiddlewareHandlerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        InvocationSettings.handler = invocationHandler
        
        #if DEBUG
            invocationHandler.enableLogger = true
            EventLogger.setupLgger()
        #else
            EventLogger.disableRemoteLogger()
        #endif
    }
}
