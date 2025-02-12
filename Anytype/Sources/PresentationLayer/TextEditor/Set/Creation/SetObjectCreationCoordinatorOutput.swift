import Foundation

@MainActor
protocol SetObjectCreationCoordinatorOutput: AnyObject {
    func showEditorScreen(data: ScreenData)
}
