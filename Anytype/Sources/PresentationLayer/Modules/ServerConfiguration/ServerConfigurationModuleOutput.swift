import Foundation

@MainActor
protocol ServerConfigurationModuleOutput: AnyObject {
    func onAddServerSelected()
}
