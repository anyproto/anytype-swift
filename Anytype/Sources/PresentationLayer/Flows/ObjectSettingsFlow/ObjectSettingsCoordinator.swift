import Foundation
import BlocksModels

protocol ObjectSettingsCoordinatorProtocol {
    func startFlow(router: EditorRouterProtocol)
}

final class ObjectSettingsCoordinator: ObjectSettingsCoordinatorProtocol,
                                       ObjectSettingswModelOutput, RelationsListModuleOutput,
                                       RelationValueCoordinatorOutput {
    
    private let document: BaseDocumentProtocol
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
    
    init(
        document: BaseDocumentProtocol,
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
        searchModuleAssembly: SearchModuleAssemblyProtocol
    ) {
        self.document = document
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
    }
    
    func startFlow(router: EditorRouterProtocol) {
        let moduleViewController = objectSettingsModuleAssembly.make(document: document, router: router, output: self)
        navigationContext.present(moduleViewController)
    }
    
    // MARK: - ObjectSettingswModelOutput
    
    func undoRedoAction() {
        let moduleViewController = undoRedoModuleAssembly.make(document: document)
        navigationContext.dismissTopPresented(animated: false)
        navigationContext.present(moduleViewController)
    }
    
    func layoutPickerAction() {
        let moduleViewController = objectLayoutPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func coverPickerAction() {
        let moduleViewController = objectCoverPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func iconPickerAction() {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func relationsAction() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.objectRelationShow)
        
        let moduleViewController = relationsListModuleAssembly.make(document: document, output: self)
        navigationContext.present(moduleViewController, animated: true, completion: nil)
    }
    
    func openPageAction(screenData: EditorScreenData) {
        editorPageCoordinator.startFlow(data: screenData, replaceCurrentPage: false)
    }
    
    func linkToAction(onSelect: @escaping (BlockId, _ typeUrl: String) -> ()) {
        let module = searchModuleAssembly.makeLinkToObjectSearch { data in
            onSelect(data.blockId, data.typeId)
        }
        navigationContext.present(module)
    }
    
    // MARK: - RelationsListModuleOutput
    
    func addNewRelationAction() {
        addNewRelationCoordinator.showAddNewRelationView { relation, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .menu)
        }
    }
    
    func editRelationValueAction(relationKey: String) {
        let relation = document.parsedRelations.all.first { $0.key == relationKey }
        guard let relation = relation else { return }
        
        relationValueCoordinator.startFlow(
            objectId: document.objectId,
            source: .object,
            relation: relation,
            output: self
        )
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func openObject(pageId: BlockId, viewType: EditorViewType) {
        navigationContext.dismissAllPresented()
        editorPageCoordinator.startFlow(data: EditorScreenData(pageId: pageId, type: viewType), replaceCurrentPage: false)
    }
}
