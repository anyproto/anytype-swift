import Foundation
import UIKit
import AnytypeCore

final class DI: DIProtocol {
    
    // MARK: - DIProtocol
    
    lazy var coordinatorsDI: CoordinatorsDIProtocol = {
        return CoordinatorsDI(serviceLocator: serviceLocator)
    }()
    
    lazy var serviceLocator: ServiceLocator = {
        return ServiceLocator()
    }()
}


extension DI {
    static var preview: DIProtocol {
        if !AppContext.isPreview {
            anytypeAssertionFailure("Preview DI available only in debug")
        }
        return DI()
    }
}
