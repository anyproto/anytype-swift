import Foundation
import Services
import AnytypeCore
import SwiftUI

@MainActor
final class ObjectSettingsCoordinatorViewModel: 
    ObservableObject,
    ObjectSettingsModelOutput,
    RelationValueCoordinatorOutput,
    ObjectVersionModuleOutput
{
    
    let objectId: String
    let spaceId: String
    private weak var output: (any ObjectSettingsCoordinatorOutput)?
    
    @Published var coverPickerData: BaseDocumentIdentifiable?
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var blockObjectSearchData: BlockObjectSearchData?
    @Published var relationsListData: PropertiesListData?
    @Published var versionHistoryData: VersionHistoryData?
    @Published var dismiss = false
    
    init(objectId: String, spaceId: String, output: (any ObjectSettingsCoordinatorOutput)?) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
    }
    
    // MARK: - ObjectSettingsModelOutput
    
    func undoRedoAction(objectId: String) {
        withAnimation(nil) {
            dismiss.toggle()
        }
        output?.didUndoRedo()
    }
    
    func showCoverPicker(document: some BaseDocumentProtocol) {
        coverPickerData = BaseDocumentIdentifiable(document: document)
    }
    
    func showIconPicker(document: some BaseDocumentProtocol) {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func relationsAction(document: some BaseDocumentProtocol) {
        AnytypeAnalytics.instance().logScreenObjectRelation()
        relationsListData = PropertiesListData(document: document)
    }
    
    func showVersionHistory(document: some BaseDocumentProtocol) {
        guard let details = document.details else { return }
        versionHistoryData = VersionHistoryData(
            objectId: document.objectId,
            spaceId: document.spaceId,
            isListType: details.isList,
            canRestore: document.permissions.canRestoreVersionHistory
        )
    }
    
    func openPageAction(screenData: ScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    func linkToAction(document: some BaseDocumentProtocol, onSelect: @escaping (String) -> ()) {
        let excludedLayouts = DetailsLayout.fileAndMediaLayouts + [.set, .participant]
        blockObjectSearchData = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: excludedLayouts,
            onSelect: { details in
                onSelect(details.id)
            }
        )
    }
    
    func closeEditorAction() {
        output?.closeEditor()
    }
    
    func didCreateLinkToItself(selfName: String, data: ScreenData) {
        output?.didCreateLinkToItself(selfName: selfName, data: data)
    }
    
    func didCreateTemplate(templateId: String) {
        output?.didCreateTemplate(templateId: templateId)
    }
    
    func didTapUseTemplateAsDefault(templateId: String) {
        output?.didTapUseTemplateAsDefault(templateId: templateId)
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func showEditorScreen(data: ScreenData) {
        Task { @MainActor in
            dismiss.toggle()
            output?.showEditorScreen(data: data)
        }
    }
    
    // MARK: - ObjectVersionModuleOutput
    
    func versionRestored(_ text: String) {
        dismiss.toggle()
        output?.versionRestored(text)
    }
}
