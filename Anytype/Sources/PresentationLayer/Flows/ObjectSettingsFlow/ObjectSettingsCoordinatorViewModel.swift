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
    
    private let navigationContext: NavigationContextProtocol
    private let relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol
    
    @Published var coverPickerData: ObjectCoverPickerData?
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var layoutPickerObjectId: StringIdentifiable?
    @Published var blockObjectSearchData: BlockObjectSearchData?
    @Published var dismiss = false
    
    init(
        objectId: String,
        output: ObjectSettingsCoordinatorOutput?,
        navigationContext: NavigationContextProtocol,
        relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol
    ) {
        self.objectId = objectId
        self.output = output
        self.navigationContext = navigationContext
        self.relationsListCoordinatorAssembly = relationsListCoordinatorAssembly
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
        
        let view = relationsListCoordinatorAssembly.make(document: document, output: self)
        navigationContext.present(view)
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
        navigationContext.dismissAllPresented(animated: true) { [weak self] in
            self?.output?.showEditorScreen(data: data)
        }
    }
}
