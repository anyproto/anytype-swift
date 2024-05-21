import Foundation
import Services

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
    func openUrl(_ url: URL)
    func showAddNewRelationView(document: BaseDocumentProtocol, onSelect: @escaping (RelationDetails, _ isNew: Bool) -> Void)
    // TODO: Refactoring templates. Delete it
    func setModuleInput(input: EditorPageModuleInput, objectId: String)
    // TODO: Open toast inside module
    func showFailureToast(message: String)
    // TODO: Migrate EditorRouter to EditorPageCoordinator and make output as MainActor
}
