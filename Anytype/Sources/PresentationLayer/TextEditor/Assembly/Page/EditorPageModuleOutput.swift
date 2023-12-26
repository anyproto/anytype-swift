import Foundation

@MainActor
protocol EditorPageModuleOutput: AnyObject {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    func closeEditor()
    // TODO: Refactoring templates. Delete it
    func setModuleInput(input: EditorPageModuleInput, objectId: String)
    // TODO: Migrate EditorRouter to EditorPageCoordinator and make output as MainActor
}
