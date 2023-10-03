import Foundation

@MainActor
protocol EditorPageModuleOutput: AnyObject {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    // Migrate EditorRouter to EditorPageCoordinator
}
