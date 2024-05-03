import Foundation
import SwiftUI
import AnytypeCore
import Services

@MainActor
final class EditorPageCoordinatorViewModel: ObservableObject, EditorPageModuleOutput, RelationValueCoordinatorOutput {
    
    private let data: EditorPageObject
    private let showHeader: Bool
    private let setupEditorInput: (EditorPageModuleInput, String) -> Void
    private let editorPageAssembly: EditorPageModuleAssemblyProtocol
    private let relationValueProcessingService: RelationValueProcessingServiceProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    @Published var relationValueData: RelationValueData?
    @Published var toastBarData: ToastBarData = .empty
    @Published var codeLanguageData: CodeLanguageListData?
    @Published var covertPickerData: ObjectCoverPickerData?
    @Published var linkToObjectData: LinkToObjectSearchModuleData?
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var textIconPickerData: TextIconPickerData?
    @Published var blockObjectSearchData: BlockObjectSearchData?
    @Published var undoRedoObjectId: StringIdentifiable?
    @Published var relationsSearchData: RelationsSearchData?
    
    init(
        data: EditorPageObject,
        showHeader: Bool,
        setupEditorInput: @escaping (EditorPageModuleInput, String) -> Void,
        editorPageAssembly: EditorPageModuleAssemblyProtocol,
        relationValueProcessingService: RelationValueProcessingServiceProtocol
    ) {
        self.data = data
        self.showHeader = showHeader
        self.setupEditorInput = setupEditorInput
        self.editorPageAssembly = editorPageAssembly
        self.relationValueProcessingService = relationValueProcessingService
    }
    
    func pageModule() -> AnyView {
        return editorPageAssembly.make(data: data, output: self, showHeader: showHeader)
    }
    
    // MARK: - EditorPageModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    func setModuleInput(input: EditorPageModuleInput, objectId: String) {
        setupEditorInput(input, objectId)
    }
    
    func showRelationValueEditingView(document: BaseDocumentProtocol, relation: Relation) {
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("Details not found")
            return
        }
        handleRelationValue(relation: relation, objectDetails: objectDetails)
    }
    
    func showCoverPicker(document: BaseDocumentGeneralProtocol) {
        covertPickerData = ObjectCoverPickerData(document: document)
    }
    
    func onSelectCodeLanguage(objectId: String, blockId: String) {
        codeLanguageData = CodeLanguageListData(documentId: objectId, blockId: blockId)
    }
    
    func showLinkToObject(data: LinkToObjectSearchModuleData) {
        linkToObjectData = data
    }
    
    func showIconPicker(document: BaseDocumentGeneralProtocol) {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func showTextIconPicker(data: TextIconPickerData) {
        textIconPickerData = data
    }
    
    func showBlockObjectSearch(data: BlockObjectSearchData) {
        blockObjectSearchData = data
    }
    
    func didUndoRedo() {
        undoRedoObjectId = data.objectId.identifiable
    }
    
    func showAddNewRelationView(document: BaseDocumentProtocol, onSelect: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        relationsSearchData = RelationsSearchData(
            document: document,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
            target: .object, 
            onRelationSelect: onSelect
        )
    }
    
    // MARK: - Private
    
    private func handleRelationValue(relation: Relation, objectDetails: ObjectDetails) {
        relationValueData = relationValueProcessingService.handleRelationValue(
            relation: relation,
            objectDetails: objectDetails,
            analyticsType: .block,
            onToastShow: { [weak self] message in
                self?.toastBarData = ToastBarData(text: message, showSnackBar: true, messageType: .none)
            }
        )
    }
}
