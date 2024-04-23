import Foundation

@MainActor
protocol EditorPageModuleOutput: AnyObject, ObjectHeaderModuleOutput {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    func closeEditor()
    func onSelectCodeLanguage(objectId: String, blockId: String)
    func showRelationValueEditingView(document: BaseDocumentProtocol, relation: Relation)
    func showLinkToObject(data: LinkToObjectSearchModuleData)
    func showIconPicker(document: BaseDocumentGeneralProtocol)
    func showTextIconPicker(data: TextIconPickerData)
    func showBlockObjectSearch(data: BlockObjectSearchData)
    func didUndoRedo()
    // TODO: Refactoring templates. Delete it
    func setModuleInput(input: EditorPageModuleInput, objectId: String)
    // TODO: Migrate EditorRouter to EditorPageCoordinator and make output as MainActor
}
