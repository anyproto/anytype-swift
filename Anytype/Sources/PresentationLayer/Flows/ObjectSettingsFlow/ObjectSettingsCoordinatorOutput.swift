import Foundation

@MainActor
protocol ObjectSettingsCoordinatorOutput: AnyObject {
    func closeEditor()
    func showEditorScreen(data: ScreenData)
    func didCreateLinkToItself(selfName: String, data: ScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
    func didUndoRedo()
    func versionRestored(_ text: String)
}
