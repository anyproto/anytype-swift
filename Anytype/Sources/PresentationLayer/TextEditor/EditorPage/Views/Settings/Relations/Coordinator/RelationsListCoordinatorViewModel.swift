import SwiftUI
import Services
import AnytypeCore

struct RelationsListData: Identifiable {
    let document: any BaseDocumentProtocol
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
    @Published var objectTypeData: EditorTypeObject?
    @Published var showTypePicker = false
    
    let document: any BaseDocumentProtocol
    
    @Injected(\.relationValueProcessingService)
    private var relationValueProcessingService: any RelationValueProcessingServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private weak var output: (any RelationValueCoordinatorOutput)?

    init(document: some BaseDocumentProtocol, output: (any RelationValueCoordinatorOutput)?) {
        self.document = document
        self.output = output
    }
    
    // MARK: - RelationsListModuleOutput
    
    func editRelationValueAction(document: some BaseDocumentProtocol, relationKey: String) {
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
        if relation.key == BundledRelationKey.type.rawValue && document.permissions.canChangeType {
            showTypePicker = true
        } else {
            relationValueData = relationValueProcessingService.handleRelationValue(
                relation: relation,
                objectDetails: objectDetails,
                analyticsType: .menu
            )
        }
    }
    
    func showTypeRelationsView(typeId: String) {
        AnytypeAnalytics.instance().logScreenEditType(route: .object)
        objectTypeData = EditorTypeObject(objectId: typeId, spaceId: document.spaceId)
    }
    
    func onTypeSelected(_ type: ObjectType) {
        showTypePicker = false
        Task {
            try await objectActionsService.setObjectType(objectId: document.objectId, typeUniqueKey: type.uniqueKey)
            AnytypeAnalytics.instance().logChangeObjectType(type.analyticsType, spaceId: document.spaceId, route: .relationsList)
        }
    }
    
    // MARK: - RelationValueCoordinatorOutput
    
    func showEditorScreen(data: ScreenData) {
        output?.showEditorScreen(data: data)
    }
}
