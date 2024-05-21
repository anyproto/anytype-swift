import Foundation

protocol DIProtocol: AnyObject {
    var coordinatorsDI: CoordinatorsDIProtocol { get }
    var serviceLocator: ServiceLocator { get }
}
