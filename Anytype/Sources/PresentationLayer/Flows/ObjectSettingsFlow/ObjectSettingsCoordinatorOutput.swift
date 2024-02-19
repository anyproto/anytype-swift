import Foundation

@MainActor
protocol ObjectSettingsCoordinatorOutput: AnyObject {
    func closeEditor()
    func showEditorScreen(data: EditorScreenData)
}
