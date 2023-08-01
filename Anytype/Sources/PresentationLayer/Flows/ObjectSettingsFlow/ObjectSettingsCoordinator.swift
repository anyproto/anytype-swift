import Foundation
import Services
import AnytypeCore

protocol ObjectSettingsCoordinatorProtocol {
    func startFlow(objectId: BlockId, delegate: ObjectSettingsModuleDelegate)
}

final class ObjectSettingsCoordinator: ObjectSettingsCoordinatorProtocol,
                                       ObjectSettingswModelOutput, RelationsListModuleOutput,
                                       RelationValueCoordinatorOutput {
    private let navigationContext: NavigationContextProtocol
    private let objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol
    private let undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol
    private let objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let relationsListModuleAssembly: RelationsListModuleAssemblyProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
        objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol,
        undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol,
        objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        relationsListModuleAssembly: RelationsListModuleAssemblyProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectSettingsModuleAssembly = objectSettingsModuleAssembly
        self.undoRedoModuleAssembly = undoRedoModuleAssembly
        self.objectLayoutPickerModuleAssembly = objectLayoutPickerModuleAssembly
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.relationsListModuleAssembly = relationsListModuleAssembly
        self.relationValueCoordinator = relationValueCoordinator
        self.editorPageCoordinator = editorPageCoordinator
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.searchModuleAssembly = searchModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    func startFlow(objectId: BlockId, delegate: ObjectSettingsModuleDelegate) {
        let document = BaseDocument(objectId: objectId)
        Task { @MainActor in
            do {
                try await document.open()
                let moduleViewController = objectSettingsModuleAssembly.make(
                    document: document,
                    output: self,
                    delegate: delegate
                )
                
                navigationContext.present(moduleViewController)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - ObjectSettingswModelOutput
    
    func undoRedoAction(document: BaseDocumentProtocol) {
        let moduleViewController = undoRedoModuleAssembly.make(document: document)
        navigationContext.dismissTopPresented(animated: false)
        navigationContext.present(moduleViewController)
    }
    
    func layoutPickerAction(document: BaseDocumentProtocol) {
        let moduleViewController = objectLayoutPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func coverPickerAction(document: BaseDocumentProtocol) {
        let moduleViewController = objectCoverPickerModuleAssembly.make(document: document, objectId: document.objectId)
        navigationContext.present(moduleViewController)
    }
    
    func iconPickerAction(document: BaseDocumentProtocol) {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document, objectId: document.objectId)
        navigationContext.present(moduleViewController)
    }
    
    func relationsAction(document: BaseDocumentProtocol) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.objectRelationShow)
        
        let moduleViewController = relationsListModuleAssembly.make(document: document, output: self)
        navigationContext.present(moduleViewController, animated: true, completion: nil)
    }
    
    func openPageAction(screenData: EditorScreenData) {
        editorPageCoordinator.startFlow(data: screenData, replaceCurrentPage: false)
    }
    
    func linkToAction(document: BaseDocumentProtocol, onSelect: @escaping (BlockId) -> ()) {
        let moduleView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedTypeIds: [ObjectTypeId.bundled(.set).rawValue]
        ) { [weak navigationContext] details in
            navigationContext?.dismissAllPresented(animated: true) {
                onSelect(details.id)
            }
        }

        navigationContext.presentSwiftUIView(view: moduleView)
    }
    
    // MARK: - RelationsListModuleOutput
    
    func addNewRelationAction(document: BaseDocumentProtocol) {
        addNewRelationCoordinator.showAddNewRelationView(
            document: document,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
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
    
    func openObject(screenData: EditorScreenData) {
        navigationContext.dismissAllPresented()
        editorPageCoordinator.startFlow(data: screenData, replaceCurrentPage: false)
    }
}
