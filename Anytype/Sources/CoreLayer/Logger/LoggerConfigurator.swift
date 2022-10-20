import Foundation
import Logger
import ProtobufMessages

final class LoggerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        #if RELEASE
            EventLogger.disableRemoteLogger()
        #else
            InvocationSettings.handler = invocationHandler
            EventLogger.setupLgger()
        #endif
    }
}
