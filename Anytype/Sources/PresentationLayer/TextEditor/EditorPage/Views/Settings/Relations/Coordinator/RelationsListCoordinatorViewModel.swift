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
    @Published var toastBarData: ToastBarData = .empty
    
    let document: BaseDocumentProtocol
    private let relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let legacyRelationValueCoordinator: LegacyRelationValueCoordinatorProtocol
    private let relationValueProcessingService: RelationValueProcessingServiceProtocol
    private weak var output: RelationValueCoordinatorOutput?

    init(
        document: BaseDocumentProtocol,
        relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        legacyRelationValueCoordinator: LegacyRelationValueCoordinatorProtocol,
        relationValueProcessingService: RelationValueProcessingServiceProtocol,
        output: RelationValueCoordinatorOutput?
    ) {
        self.document = document
        self.relationValueCoordinatorAssembly = relationValueCoordinatorAssembly
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.legacyRelationValueCoordinator = legacyRelationValueCoordinator
        self.relationValueProcessingService = relationValueProcessingService
        self.output = output
    }
    
    // MARK: - RelationsListModuleOutput
    
    func addNewRelationAction(document: BaseDocumentProtocol) {
        addNewRelationCoordinator.showAddNewRelationView(
            document: document,
            excludedRelationsIds: document.parsedRelations.installedInObject.map(\.id),
            target: .object,
            onCompletion: { [spaceId = document.spaceId] relation, isNew in
                AnytypeAnalytics.instance().logAddExistingOrCreateRelation(format: relation.format, isNew: isNew, type: .menu, spaceId: spaceId)
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
        let analyticsType = AnalyticsEventsRelationType.menu
        if relationValueProcessingService.canOpenRelationInNewModule(relation) {
            relationValueData = RelationValueData(
                relation: relation,
                objectDetails: objectDetails
            )
            return
        }
        
        let result = relationValueProcessingService.relationProcessedSeparately(
            relation: relation,
            objectId: objectDetails.id,
            spaceId: objectDetails.spaceId,
            analyticsType: analyticsType,
            onToastShow: { [weak self] message in
                self?.toastBarData = ToastBarData(text: message, showSnackBar: true, messageType: .none)
            }
        )
        
        if !result {
            legacyRelationValueCoordinator.startFlow(
                objectDetails: objectDetails,
                relation: relation,
                analyticsType: analyticsType,
                output: self
            )
        }
    }
    
    // MARK: - RelationValueCoordinatorOutput
    func showEditorScreen(data: EditorScreenData) {
        output?.showEditorScreen(data: data)
    }
}
