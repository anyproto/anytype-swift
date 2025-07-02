import Foundation

enum SpacePreferredPresentationMode {
    case widgets
    case chat
}

@MainActor
protocol SpaceHubModuleOutput: AnyObject {
    func onSelectCreateObject()
    func onSelectSpace(spaceId: String, preferredPresentation: SpacePreferredPresentationMode?)
}

extension SpaceHubModuleOutput {
    func onSelectSpace(spaceId: String) {
        onSelectSpace(spaceId: spaceId, preferredPresentation: nil)
    }
}
