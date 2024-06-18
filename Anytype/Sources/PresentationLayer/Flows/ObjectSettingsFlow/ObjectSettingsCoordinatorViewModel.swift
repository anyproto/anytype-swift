import Foundation
import Services
import AnytypeCore
import SwiftUI

@MainActor
final class ObjectSettingsCoordinatorViewModel: ObservableObject,
                                                ObjectSettingsModelOutput,
                                                RelationValueCoordinatorOutput {
    
    let objectId: String
    private weak var output: ObjectSettingsCoordinatorOutput?
    
    private var dismissAllPresented: DismissAllPresented?
    
    @Published var coverPickerData: ObjectCoverPickerData?
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var layoutPickerObjectId: StringIdentifiable?
    @Published var blockObjectSearchData: BlockObjectSearchData?
    @Published var relationsListData: RelationsListData?
    @Published var dismiss = false
    
    init(objectId: String, output: ObjectSettingsCoordinatorOutput?) {
        self.objectId = objectId
        self.output = output
    }
    
    func setDismissAllPresented(dismissAllPresented: DismissAllPresented) {
        self.dismissAllPresented = dismissAllPresented
    }
    
    // MARK: - ObjectSettingsModelOutput
    
    func undoRedoAction(objectId: String) {
        withAnimation(nil) {
            dismiss.toggle()
        }
        output?.didUndoRedo()
    }
    
    func layoutPickerAction(document: BaseDocumentProtocol) {
        layoutPickerObjectId = document.objectId.identifiable
    }
    
    func showCoverPicker(document: BaseDocumentGeneralProtocol) {
        coverPickerData = ObjectCoverPickerData(document: document)
    }
    
    func showIconPicker(document: BaseDocumentGeneralProtocol) {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func relationsAction(document: BaseDocumentProtocol) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.objectRelationShow)
        relationsListData = RelationsListData(document: document)
    }
    
    func openPageAction(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (String) -> ()) {
        let excludedLayouts = DetailsLayout.fileLayouts + [.set, .participant]
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
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        output?.didCreateLinkToItself(selfName: selfName, data: data)
    }
    
    func didCreateTemplate(templateId: String) {
        output?.didCreateTemplate(templateId: templateId)
    }
    
    func didTapUseTemplateAsDefault(templateId: String) {
        output?.didTapUseTemplateAsDefault(templateId: templateId)
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        Task { @MainActor in
            await dismissAllPresented?()
            output?.showEditorScreen(data: data)
        }
    }
}
