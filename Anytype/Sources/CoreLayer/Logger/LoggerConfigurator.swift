import Foundation
import Logger
import ProtobufMessages
import PulseCore

final class LoggerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        InvocationSettings.handler = invocationHandler
        EventLogger.setupLgger()
        Experimental.URLSessionProxy.shared.isEnabled = true
    }
}
