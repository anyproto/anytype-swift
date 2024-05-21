import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    func home() -> HomeCoordinatorAssemblyProtocol
    func application() -> ApplicationCoordinatorAssemblyProtocol
    func editor() -> EditorCoordinatorAssemblyProtocol
}
