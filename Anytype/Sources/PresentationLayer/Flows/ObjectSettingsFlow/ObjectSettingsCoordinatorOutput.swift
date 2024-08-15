import Foundation

@MainActor
protocol ObjectSettingsCoordinatorOutput: AnyObject {
    func closeEditor()
    func showEditorScreen(data: EditorScreenData)
    func didCreateLinkToItself(selfName: String, data: EditorScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
    func didUndoRedo()
    func versionRestored(_ text: String)
}
