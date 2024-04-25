import Foundation
import Services

@MainActor
protocol EditorSetModuleOutput: AnyObject, ObjectHeaderModuleOutput {
    func showEditorScreen(data: EditorScreenData)
    func replaceEditorScreen(data: EditorScreenData)
    func closeEditor()
    
    func showSetViewPicker(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage)
    func showSetViewSettings(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage)
    func showQueries(document: SetDocumentProtocol, selectedObjectId: String?, onSelect: @escaping (String) -> ())

    // NavigationContext
    func showCreateObject(document: SetDocumentProtocol, setting: ObjectCreationSetting?)
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    )
    func showSettings()
    func showCoverPicker(document: BaseDocumentGeneralProtocol)
    func showIconPicker(document: BaseDocumentGeneralProtocol)
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation)
    func showSetObjectCreationSettings(
        document: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    )
    func showFailureToast(message: String)
}
