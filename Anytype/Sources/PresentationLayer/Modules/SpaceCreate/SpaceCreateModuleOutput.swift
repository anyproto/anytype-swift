import Foundation

@MainActor
protocol SpaceCreateModuleOutput: AnyObject {
    func spaceCreateWillDismiss()
}
