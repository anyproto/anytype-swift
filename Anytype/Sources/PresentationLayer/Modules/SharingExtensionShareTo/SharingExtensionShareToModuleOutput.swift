import Foundation

@MainActor
protocol SharingExtensionShareToModuleOutput: AnyObject {
    func shareToFinished()
}
