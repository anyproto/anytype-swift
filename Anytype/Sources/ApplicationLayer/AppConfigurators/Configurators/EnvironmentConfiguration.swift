import Foundation
import AnytypeCore
import AppTarget

final class EnvironmentConfiguration: AppConfiguratorProtocol {
        
    func configure() {
        #if DEBUG
            CoreEnvironment.targetType = .debug
        #elseif RELEASE_ANYTYPE
            CoreEnvironment.targetType = .releaseAnytype
        #elseif RELEASE_ANYAPP
            CoreEnvironment.targetType = .releaseAnyApp
        #endif
    }
}
