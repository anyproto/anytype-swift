import SwiftUI
import Services
import AnytypeCore

struct PropertiesListData: Identifiable {
    let document: any BaseDocumentProtocol
    var id: String { document.objectId }
}

@MainActor
final class PropertiesListCoordinatorViewModel:
    ObservableObject,
    PropertiesListModuleOutput,
    PropertyValueCoordinatorOutput
{
    @Published var relationValueData: PropertyValueData?
    @Published var relationsSearchData: PropertiesSearchData?
    @Published var objectTypeData: EditorTypeObject?
    @Published var showTypePicker = false
    
    let document: any BaseDocumentProtocol
    
    @Injected(\.propertyValueProcessingService)
    private var propertyValueProcessingService: any PropertyValueProcessingServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private weak var output: (any PropertyValueCoordinatorOutput)?

    init(document: some BaseDocumentProtocol, output: (any PropertyValueCoordinatorOutput)?) {
        self.document = document
        self.output = output
    }
    
    // MARK: - PropertiesListModuleOutput
    
    func editRelationValueAction(document: some BaseDocumentProtocol, relationKey: String) {
        let relation = document.parsedProperties.installed.first { $0.key == relationKey }
        guard let relation = relation else {
            anytypeAssertionFailure("Relation not found")
            return
        }
        
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("Detaiils not found")
            return
        }
        
        handlePropertyValue(relation: relation, objectDetails: objectDetails)
    }
    
    private func handlePropertyValue(relation: Relation, objectDetails: ObjectDetails) {
        if relation.key == BundledPropertyKey.type.rawValue && document.permissions.canChangeType {
            showTypePicker = true
        } else {
            relationValueData = propertyValueProcessingService.handlePropertyValue(
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
    
    // MARK: - PropertyValueCoordinatorOutput
    
    func showEditorScreen(data: ScreenData) {
        output?.showEditorScreen(data: data)
    }
}
