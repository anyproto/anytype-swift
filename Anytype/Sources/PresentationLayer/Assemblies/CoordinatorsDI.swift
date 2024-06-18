import Foundation
import UIKit

extension Container {
    var legacySetObjectCreationCoordinator: Factory<SetObjectCreationCoordinatorProtocol> {
        self { SetObjectCreationCoordinator() }
    }
    
    var legacySharingTip: Factory<SharingTipCoordinatorProtocol> {
        self { SharingTipCoordinator() }
    }
    
    var legacyTemplatesCoordinator: Factory<TemplatesCoordinatorProtocol> {
        self { TemplatesCoordinator() }
    }
    
    var legacySetObjectCreationSettingsCoordinator: Factory<SetObjectCreationSettingsCoordinatorProtocol> {
        self { SetObjectCreationSettingsCoordinator() }
    }
}
