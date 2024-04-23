import Foundation
import Services
import AnytypeCore

@MainActor
final class ObjectSettingsCoordinatorViewModel: ObservableObject,
                                                ObjectSettingsModelOutput,
                                                RelationValueCoordinatorOutput {
    
    let objectId: String
    private weak var output: ObjectSettingsCoordinatorOutput?
    
    private let navigationContext: NavigationContextProtocol
    private let relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    @Published var coverPickerData: ObjectCoverPickerData?
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var layoutPickerObjectId: StringIdentifiable?
    
    init(
        objectId: String,
        output: ObjectSettingsCoordinatorOutput?,
        navigationContext: NavigationContextProtocol,
        relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.objectId = objectId
        self.output = output
        self.navigationContext = navigationContext
        self.relationsListCoordinatorAssembly = relationsListCoordinatorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    // MARK: - ObjectSettingsModelOutput
    
    func undoRedoAction(objectId: String) {
        // TODO: Move to editor
        navigationContext.dismissTopPresented(animated: false)
        navigationContext.present(UndoRedoViewController(objectId: objectId))
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
        let moduleView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: excludedLayouts
        ) { [weak navigationContext] details in
            navigationContext?.dismissAllPresented(animated: true) {
                onSelect(details.id)
            }
        }

        navigationContext.presentSwiftUIView(view: moduleView)
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
