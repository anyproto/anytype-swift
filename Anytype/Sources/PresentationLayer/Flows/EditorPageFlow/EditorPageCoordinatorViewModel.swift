import Foundation
import SwiftUI
import AnytypeCore
import Services

@MainActor
final class EditorPageCoordinatorViewModel: ObservableObject, EditorPageModuleOutput, PropertyValueCoordinatorOutput {
    
    let data: EditorPageObject
    let showHeader: Bool
    private let setupEditorInput: (any EditorPageModuleInput, String) -> Void
    @Injected(\.propertyValueProcessingService)
    private var propertyValueProcessingService: any PropertyValueProcessingServiceProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    @Published var relationValueData: PropertyValueData?
    @Published var toastBarData: ToastBarData?
    @Published var codeLanguageData: CodeLanguageListData?
    @Published var covertPickerData: BaseDocumentIdentifiable?
    @Published var linkToObjectData: LinkToObjectSearchModuleData?
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var textIconPickerData: TextIconPickerData?
    @Published var blockObjectSearchData: BlockObjectSearchData?
    @Published var undoRedoObjectId: StringIdentifiable?
    @Published var relationsSearchData: PropertiesSearchData?
    @Published var openUrlData: URL?
    @Published var syncStatusSpaceId: StringIdentifiable?
    @Published var settingsOutput: ObjectSettingsCoordinatorOutputIdentifiable?
    @Published var cameraData: SimpleCameraData?
    
    init(
        data: EditorPageObject,
        showHeader: Bool,
        setupEditorInput: @escaping (any EditorPageModuleInput, String) -> Void
    ) {
        self.data = data
        self.showHeader = showHeader
        self.setupEditorInput = setupEditorInput
    }
    
    // MARK: - EditorPageModuleOutput
    
    func showEditorScreen(data: ScreenData) {
        pageNavigation?.open(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    func setModuleInput(input: some EditorPageModuleInput, objectId: String) {
        setupEditorInput(input, objectId)
    }
    
    func showRelationValueEditingView(document: some BaseDocumentProtocol, relation: Property) {
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("Details not found")
            return
        }
        handlePropertyValue(relation: relation, objectDetails: objectDetails)
    }
    
    func showCoverPicker(document: some BaseDocumentProtocol) {
        covertPickerData = BaseDocumentIdentifiable(document: document)
    }
    
    func onSelectCodeLanguage(objectId: String, spaceId: String, blockId: String) {
        codeLanguageData = CodeLanguageListData(documentId: objectId, spaceId: spaceId, blockId: blockId)
    }
    
    func showLinkToObject(data: LinkToObjectSearchModuleData) {
        linkToObjectData = data
    }
    
    func showIconPicker(document: some BaseDocumentProtocol) {
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
    
    func versionRestored(_ text: String) {
        toastBarData = ToastBarData(Loc.VersionHistory.Toast.message(text), type: .neutral)
    }
    
    func showAddPropertyInfoView(document: some BaseDocumentProtocol, onSelect: @escaping (PropertyDetails, _ isNew: Bool) -> Void) {
        guard let details = document.details else { return }
        relationsSearchData = PropertiesSearchData(
            objectId: details.type,
            spaceId: document.spaceId,
            excludedRelationsIds: document.parsedProperties.installed.map(\.id),
            target: .object(objectId: details.id),
            onRelationSelect: onSelect
        )
    }
    
    func openUrl(_ url: URL) {
        openUrlData = url
    }
    
    func showFailureToast(message: String) {
        toastBarData = ToastBarData(message, type: .failure)
    }
    
    func showSyncStatusInfo(spaceId: String) {
        syncStatusSpaceId = spaceId.identifiable
    }
    
    func showObectSettings(output: any ObjectSettingsCoordinatorOutput) {
        settingsOutput = ObjectSettingsCoordinatorOutputIdentifiable(value: output)
    }
    
    func showCamera(_ data: SimpleCameraData) {
        cameraData = data
    }
    
    // MARK: - Private
    
    private func handlePropertyValue(relation: Property, objectDetails: ObjectDetails) {
        relationValueData = propertyValueProcessingService.handlePropertyValue(
            relation: relation,
            objectDetails: objectDetails,
            analyticsType: .block
        )
    }
}
