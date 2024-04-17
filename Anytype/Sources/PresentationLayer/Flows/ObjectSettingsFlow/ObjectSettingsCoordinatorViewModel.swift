import Foundation
import Services
import AnytypeCore

@MainActor
final class ObjectSettingsCoordinatorViewModel: ObservableObject,
                                                ObjectSettingsModelOutput,
                                                RelationValueCoordinatorOutput {
    
    let objectId: String
    private weak var output: ObjectSettingsCoordinatorOutput?
    let objectSettingsHandler: (ObjectSettingsAction) -> Void
    
    private let navigationContext: NavigationContextProtocol
    private let objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    
    init(
        objectId: String,
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void,
        navigationContext: NavigationContextProtocol,
        objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        relationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.objectId = objectId
        self.output = output
        self.objectSettingsHandler = objectSettingsHandler
        self.navigationContext = navigationContext
        self.objectLayoutPickerModuleAssembly = objectLayoutPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
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
        let moduleViewController = objectLayoutPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func showCoverPicker(document: BaseDocumentGeneralProtocol, onCoverAction: @escaping (ObjectCoverPickerAction) -> Void) {
        let data = ObjectCoverPickerData(document: document, onCoverAction: onCoverAction)
        navigationContext.present(ObjectCoverPicker(data: data))
    }
    
    func showIconPicker(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document, onIconAction: onIconAction)
        navigationContext.present(moduleViewController)
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
