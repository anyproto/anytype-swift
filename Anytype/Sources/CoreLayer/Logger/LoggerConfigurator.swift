import Foundation
import Logger
import ProtobufMessages
import PulseCore

final class LoggerConfigurator: AppConfiguratorProtocol {
    
    private let invocationHandler = InvocationMesagesHandler()
    
    func configure() {
        #if RELEASE
            RemoteLogger.shared.disable()
        #else
            LoggerStore.databaseSizeLimit = 1024 * 1024 * 15 // 15 MB
            LoggerStore.blobsSizeLimit = 1024 * 1024 * 50 // 50 MB
            InvocationSettings.handler = invocationHandler
            EventLogger.setupLgger()
            Experimental.URLSessionProxy.shared.isEnabled = true
        #endif
    }
}
