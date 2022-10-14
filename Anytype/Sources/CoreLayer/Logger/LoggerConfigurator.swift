import Foundation
import Logger
import ProtobufMessages

final class LoggerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        #if RELEASE
            RemoteLogger.shared.disable()
        #else
            InvocationSettings.handler = invocationHandler
            EventLogger.setupLgger()
        #endif
    }
}
