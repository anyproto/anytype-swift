import Foundation

@MainActor
protocol ObjectActionsOutput: AnyObject {
    func undoRedoAction()
    func openPageAction(screenData: ScreenData)
    func closeEditorAction()
    func onLinkItselfAction(onSelect: @escaping (String) -> Void)
    func onNewTemplateCreation(templateId: String)
    func onTemplateMakeDefault(templateId: String)
    func onLinkItselfToObjectHandler(data: ScreenData)
}
