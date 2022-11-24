import Foundation
import Logger
import ProtobufMessages

final class LoggerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        #if DEBUG
            InvocationSettings.handler = invocationHandler
            EventLogger.setupLgger()
        #else
            EventLogger.disableRemoteLogger()
        #endif
    }
}
