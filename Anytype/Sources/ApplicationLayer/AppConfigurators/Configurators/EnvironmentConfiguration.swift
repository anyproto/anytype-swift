import Foundation
import AnytypeCore

final class EnvironmentConfiguration: AppConfiguratorProtocol {
        
    func configure() {
        #if DEBUG
        CoreEnvironment.isDebug = true
        #else
        CoreEnvironment.isDebug = false
        #endif
    }
}
