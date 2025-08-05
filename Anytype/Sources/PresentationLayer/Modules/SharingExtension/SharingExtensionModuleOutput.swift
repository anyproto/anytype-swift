import Foundation

@MainActor
protocol SharingExtensionModuleOutput: AnyObject {
    func onSelectDataSpace(spaceId: String)
}
