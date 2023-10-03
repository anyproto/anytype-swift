import Foundation

@MainActor
protocol EditorSetModuleOutput: AnyObject {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    // Migrate EditorSetRouter to EditorSetCoordinator
}
