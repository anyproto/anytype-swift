import Foundation
import Services
import SwiftProtobuf
import AnytypeCore
import Combine
import SwiftUI


@MainActor
final class TypeFieldsViewModel: ObservableObject {
        
    @Published var canEditRelationsList = false
    @Published var editMode = EditMode.inactive
    @Published var relations = [TypeFieldsRelationsData]()
    @Published var relationsSearchData: RelationsSearchData?
    
    // MARK: - Private variables
    
    let document: any BaseDocumentProtocol
    private let fieldsDataBuilder = TypeFieldsRelationsDataBuilder()
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    private weak var output: (any RelationsListModuleOutput)?
    
    // MARK: - Initializers
    
    convenience init(
        data: EditorTypeObject,
        output: (any RelationsListModuleOutput)?
    ) {
        let document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
        self.init(document: document, output: output)
    }
    
    init(
        document: some BaseDocumentProtocol,
        output: (any RelationsListModuleOutput)?
    ) {
        self.document = document
        self.output = output
    }
    
    func setupSubscriptions() async {
        async let relationsSubscription: () = setupRelationsSubscription()
        async let permissionSubscription: () = setupPermissionSubscription()
        
        (_, _) = await (relationsSubscription, permissionSubscription)
    }
    
    private func setupRelationsSubscription() async {
        for await parsedRelations in document.parsedRelationsPublisher.values {
            relations = fieldsDataBuilder.build(parsedRelations: parsedRelations)
        }
    }
    
    private func setupPermissionSubscription() async {
        for await permissions in document.permissionsPublisher.values {
            canEditRelationsList = permissions.canEditRelationsList
            editMode = canEditRelationsList ? .active : .inactive
        }
    }
    
    func onAddRelationTap(section: TypeFieldsRelationsSection) {
        relationsSearchData = RelationsSearchData(
            document: document,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
            target: .object,
            onRelationSelect: { [weak self] details, isNew in
                if section == .header { self?.featureRelation(key: details.key) }
            }
        )
    }
    
    private func featureRelation(key: String) {
        Task {
            try await relationsService.addFeaturedRelation(objectId: document.objectId, relationKey: key)
        }
    }
    
    func removeRelation(relation: Relation) {
        Task {
            try await relationsService.removeRelation(objectId: document.objectId, relationKey: relation.key)
            let relationDetails = try relationDetailsStorage.relationsDetails(for: relation.key, spaceId: document.spaceId)
            AnytypeAnalytics.instance().logDeleteRelation(spaceId: document.spaceId, format: relationDetails.format, key: relationDetails.analyticsKey)
        }
    }
}
