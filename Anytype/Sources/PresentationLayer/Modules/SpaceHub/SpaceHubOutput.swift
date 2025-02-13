import Foundation

@MainActor
protocol SpaceHubModuleOutput: AnyObject {
    func onSelectCreateObject()
}
