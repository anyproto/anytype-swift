import Foundation

@MainActor
protocol SharingExtensionModuleOutput: AnyObject {
    func onSelectDataSpce(spaceId: String)
}
