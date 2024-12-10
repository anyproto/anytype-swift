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
    
    // MARK: - Initializers
    
    convenience init(data: EditorTypeObject) {
        let document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
        self.init(document: document)
    }
    
    init(document: some BaseDocumentProtocol) {
        self.document = document
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
            objectId: document.objectId,
            spaceId: document.spaceId,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
            target: .object,
            onRelationSelect: { [weak self] details, isNew in
                if section == .header { self?.featureRelation(key: details.key) }
            }
        )
    }
    
    func onDeleteRelations(_ indexes: IndexSet) {
        let keys = indexes.map { relations[$0].relation.key }
        
        Task {
            try await relationsService.removeRelations(objectId: document.objectId, relationKeys: keys)
        }
    }
    
    private func featureRelation(key: String) {
        Task {
            try await relationsService.addFeaturedRelation(objectId: document.objectId, relationKey: key)
        }
    }
}
