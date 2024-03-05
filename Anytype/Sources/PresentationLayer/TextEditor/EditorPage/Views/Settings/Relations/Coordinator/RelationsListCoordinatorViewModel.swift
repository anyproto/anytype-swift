import SwiftUI
import Services
import AnytypeCore


@MainActor
final class RelationsListCoordinatorViewModel:
    ObservableObject,
    RelationsListModuleOutput,
    RelationValueCoordinatorOutput
{
    @Published var relationValueData: RelationValueData?
    @Published var dismiss: Bool = false
    
    private let document: BaseDocumentProtocol
    private let relationsListModuleAssembly: RelationsListModuleAssemblyProtocol
    private let relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let legacyRelationValueCoordinator: LegacyRelationValueCoordinatorProtocol
    private weak var output: RelationValueCoordinatorOutput?

    init(
        document: BaseDocumentProtocol,
        relationsListModuleAssembly: RelationsListModuleAssemblyProtocol,
        relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        legacyRelationValueCoordinator: LegacyRelationValueCoordinatorProtocol,
        output: RelationValueCoordinatorOutput?
    ) {
        self.document = document
        self.relationsListModuleAssembly = relationsListModuleAssembly
        self.relationValueCoordinatorAssembly = relationValueCoordinatorAssembly
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.legacyRelationValueCoordinator = legacyRelationValueCoordinator
        self.output = output
    }
    
    func relationsList() -> AnyView {
        relationsListModuleAssembly.make(document: document, output: self)
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
        
        handleRelationValue(relation: relation, objectDetails: objectDetails)
    }
    
    func relationValueCoordinator(data: RelationValueData) -> AnyView {
        relationValueCoordinatorAssembly.make(
            relation: data.relation,
            objectDetails: data.objectDetails,
            analyticsType: .menu,
            output: self
        )
    }
    
    private func handleRelationValue(relation: Relation, objectDetails: ObjectDetails) {
        if RelationValueInteractor.canHandleRelation(relation) {
            relationValueData = RelationValueData(
                relation: relation,
                objectDetails: objectDetails
            )
        } else {
            legacyRelationValueCoordinator.startFlow12(
                objectDetails: objectDetails,
                relation: relation,
                analyticsType: .menu,
                output: self
            )
        }
    }
    
    // MARK: - RelationValueCoordinatorOutput
    func showEditorScreen(data: EditorScreenData) {
        output?.showEditorScreen(data: data)
    }
}

extension RelationsListCoordinatorViewModel {
    struct RelationValueData: Identifiable {
        let id = UUID()
        let relation: Relation
        let objectDetails: ObjectDetails
    }
}

