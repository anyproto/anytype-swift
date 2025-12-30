import Foundation
import Services
import AnytypeCore
import SwiftUI

@MainActor
@Observable
final class ObjectSettingsCoordinatorViewModel:
    ObjectSettingsModelOutput,
    PropertyValueCoordinatorOutput,
    ObjectVersionModuleOutput
{

    let objectId: String
    let spaceId: String
    private weak var output: (any ObjectSettingsCoordinatorOutput)?

    var coverPickerData: BaseDocumentIdentifiable?
    var objectIconPickerData: ObjectIconPickerData?
    var blockObjectSearchData: BlockObjectSearchData?
    var relationsListData: PropertiesListData?
    var versionHistoryData: VersionHistoryData?
    var publishingData: PublishToWebViewData?
    var dismiss = false
    
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
    
    func showPublising(document: some BaseDocumentProtocol) {
        publishingData = PublishToWebViewData(objectId: document.objectId, spaceId: document.spaceId)
    }
    
    func openPageAction(screenData: ScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    func linkToAction(document: some BaseDocumentProtocol, onSelect: @escaping (String) -> ()) {
        let excludedLayouts = DetailsLayout.fileAndMediaLayouts + [.set, .participant, .objectType]
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
    
    // MARK: - PropertyValueCoordinatorOutput
    
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
