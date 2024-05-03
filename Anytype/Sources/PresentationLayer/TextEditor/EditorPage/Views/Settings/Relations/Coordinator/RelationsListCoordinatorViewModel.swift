import SwiftUI
import Services
import AnytypeCore

struct RelationsListData: Identifiable {
    let document: BaseDocumentProtocol
    var id: String { document.objectId }
}

@MainActor
final class RelationsListCoordinatorViewModel:
    ObservableObject,
    RelationsListModuleOutput,
    RelationValueCoordinatorOutput
{
    @Published var relationValueData: RelationValueData?
    @Published var relationsSearchData: RelationsSearchData?
    @Published var toastBarData: ToastBarData = .empty
    
    let document: BaseDocumentProtocol
    
    @Injected(\.relationValueProcessingService)
    private var relationValueProcessingService: RelationValueProcessingServiceProtocol
    
    private weak var output: RelationValueCoordinatorOutput?

    init(document: BaseDocumentProtocol, output: RelationValueCoordinatorOutput?) {
        self.document = document
        self.output = output
    }
    
    // MARK: - RelationsListModuleOutput
    
    func addNewRelationAction(document: BaseDocumentProtocol) {
        relationsSearchData = RelationsSearchData(
            document: document,
            excludedRelationsIds: document.parsedRelations.installedInObject.map(\.id),
            target: .object, 
            onRelationSelect: { relationDetails, isNew in
                AnytypeAnalytics.instance().logAddExistingOrCreateRelation(format: relationDetails.format, isNew: isNew, type: .menu, spaceId: document.spaceId)
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
    
    private func handleRelationValue(relation: Relation, objectDetails: ObjectDetails) {
        relationValueData = relationValueProcessingService.handleRelationValue(
            relation: relation,
            objectDetails: objectDetails,
            analyticsType: .menu,
            onToastShow: { [weak self] message in
                self?.toastBarData = ToastBarData(text: message, showSnackBar: true, messageType: .none)
            }
        )
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        output?.showEditorScreen(data: data)
    }
}
