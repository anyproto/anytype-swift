import Foundation

protocol DIProtocol: AnyObject {
    var coordinatorsDI: CoordinatorsDIProtocol { get }
    var modulesDI: ModulesDIProtocol { get }
    var uihelpersDI: UIHelpersDIProtocol { get }
    var serviceLocator: ServiceLocator { get }
    var widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol { get }
}
