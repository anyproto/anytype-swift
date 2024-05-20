import Foundation

protocol DIProtocol: AnyObject {
    var coordinatorsDI: CoordinatorsDIProtocol { get }
    var modulesDI: ModulesDIProtocol { get }
    var serviceLocator: ServiceLocator { get }
}
