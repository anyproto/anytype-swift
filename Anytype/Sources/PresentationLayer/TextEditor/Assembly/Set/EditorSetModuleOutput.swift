import Foundation

@MainActor
protocol EditorSetModuleOutput: AnyObject {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    func closeEditor()
    // Migrate EditorSetRouter to EditorSetCoordinator
}
