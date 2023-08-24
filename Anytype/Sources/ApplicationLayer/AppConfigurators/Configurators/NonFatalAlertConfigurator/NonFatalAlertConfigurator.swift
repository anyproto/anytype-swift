import Foundation
import Logger

final class NonFatalAlertConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        AssertionLogger.shared.addHandler(NonFatalLoggerHandler())
    }
}
