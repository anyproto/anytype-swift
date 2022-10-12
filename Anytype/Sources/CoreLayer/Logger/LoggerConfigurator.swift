import Foundation
import Logger
import ProtobufMessages
import Pulse

final class LoggerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        #if RELEASE
            RemoteLogger.shared.disable()
        #else
            InvocationSettings.handler = invocationHandler
            EventLogger.setupLgger()
            Experimental.URLSessionProxy.shared.isEnabled = true
        #endif
    }
}
