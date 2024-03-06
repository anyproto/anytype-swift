import Foundation
import Services
import AnytypeCore

@MainActor
protocol ObjectSettingsCoordinatorProtocol {
    func startFlow(
        objectId: String,
        delegate: ObjectSettingsModuleDelegate,
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void
    )
}

@MainActor
final class ObjectSettingsCoordinator: ObjectSettingsCoordinatorProtocol,
                                       ObjectSettingsModelOutput, RelationsListModuleOutput,
                                       RelationValueCoordinatorOutput {
    private let navigationContext: NavigationContextProtocol
    private let objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol
    private let undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol
    private let objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let relationsListModuleAssembly: RelationsListModuleAssemblyProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let documentsProvider: DocumentsProviderProtocol
    
    private weak var output: ObjectSettingsCoordinatorOutput?
    
    init(
        navigationContext: NavigationContextProtocol,
        objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol,
        undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol,
        objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        relationsListModuleAssembly: RelationsListModuleAssemblyProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectSettingsModuleAssembly = objectSettingsModuleAssembly
        self.undoRedoModuleAssembly = undoRedoModuleAssembly
        self.objectLayoutPickerModuleAssembly = objectLayoutPickerModuleAssembly
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.relationsListModuleAssembly = relationsListModuleAssembly
        self.relationValueCoordinator = relationValueCoordinator
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.searchModuleAssembly = searchModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.documentsProvider = documentsProvider
    }
    
    func startFlow(
        objectId: String,
        delegate: ObjectSettingsModuleDelegate,
        output: ObjectSettingsCoordinatorOutput?,
        objectSettingsHandler: @escaping (ObjectSettingsAction) -> Void
    ) {
        self.output = output
        let document = documentsProvider.document(objectId: objectId, forPreview: false)
        Task { @MainActor in
            do {
                try await document.open()
                let moduleViewController = objectSettingsModuleAssembly.make(
                    document: document,
                    output: self,
                    delegate: delegate,
                    actionHandler: objectSettingsHandler
                )
                
                navigationContext.present(moduleViewController)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - ObjectSettingsModelOutput
    
    func undoRedoAction(document: BaseDocumentProtocol) {
        let moduleViewController = undoRedoModuleAssembly.make(document: document)
        navigationContext.dismissTopPresented(animated: false)
        navigationContext.present(moduleViewController)
    }
    
    func layoutPickerAction(document: BaseDocumentProtocol) {
        let moduleViewController = objectLayoutPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func showCoverPicker(document: BaseDocumentGeneralProtocol, onCoverAction: @escaping (ObjectCoverPickerAction) -> Void) {
        let moduleViewController = objectCoverPickerModuleAssembly.make(
            document: document,
            onCoverAction: onCoverAction
        )
        navigationContext.present(moduleViewController)
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
        
        let moduleViewController = relationsListModuleAssembly.make(document: document, output: self)
        navigationContext.present(moduleViewController, animated: true, completion: nil)
    }
    
    func openPageAction(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (String) -> ()) {
        let moduleView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: [.set, .participant]
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
    
    // MARK: - RelationsListModuleOutput
    
    func addNewRelationAction(document: BaseDocumentProtocol) {
        addNewRelationCoordinator.showAddNewRelationView(
            document: document,
            excludedRelationsIds: document.parsedRelations.installedInObject.map(\.id),
            target: .object,
            onCompletion: { relation, isNew in
                AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .menu)
            }
        )
    }
    
    func editRelationValueAction(document: BaseDocumentProtocol, relationKey: String) {
        let relation = document.parsedRelations.installed.first { $0.key == relationKey }
        guard let relation = relation else {
            anytypeAssertionFailure("Relation not found")
            return
        }
        
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("Detaiils not found")
            return
        }
        
        relationValueCoordinator.startFlow(
            objectDetails: objectDetails,
            relation: relation,
            analyticsType: .menu,
            output: self
        )
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        navigationContext.dismissAllPresented(animated: true) { [weak self] in
            self?.output?.showEditorScreen(data: data)
        }
    }
}
