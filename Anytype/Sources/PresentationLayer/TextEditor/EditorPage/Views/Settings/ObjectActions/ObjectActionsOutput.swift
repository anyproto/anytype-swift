import Foundation

@MainActor
protocol ObjectActionsOutput: AnyObject {
    func undoRedoAction()
    func openPageAction(screenData: EditorScreenData)
    func closeEditorAction()
    func onLinkItselfAction(onSelect: @escaping (String) -> Void)
    func onNewTemplateCreation(templateId: String)
    func onTemplateMakeDefault(templateId: String)
    func onLinkItselfToObjectHandler(data: EditorScreenData)
}
