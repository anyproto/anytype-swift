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
    @Published var relationRows = [TypeFieldsRow]()
    @Published var relationsSearchData: RelationsSearchData?
    
    // MARK: - Private variables
    
    let document: any BaseDocumentProtocol
    private let fieldsDataBuilder = TypeFieldsRowBuilder()
    private let moveHandler = TypeFieldsMoveHandler()
    
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
        for await relations in document.parsedRelationsPublisherForType.values {
            self.relationRows = fieldsDataBuilder.build(relations: relations.sidebarRelations, featured: relations.featuredRelations)
        }
    }
    
    private func setupPermissionSubscription() async {
        for await permissions in document.permissionsPublisher.values {
            canEditRelationsList = permissions.canEditRelationsList
            editMode = canEditRelationsList ? .active : .inactive
        }
    }
    
    func onAddRelationTap(section: TypeFieldsSectionRow) {
        relationsSearchData = RelationsSearchData(
            objectId: document.objectId,
            spaceId: document.spaceId,
            excludedRelationsIds: relationRows.compactMap(\.relationId),
            target: .type(isFeatured: section.isHeader),
            onRelationSelect: { _, _ in }
        )
    }
    
    func onDeleteRelations(_ indexes: IndexSet) {
        Task {
            let relationsIds = indexes.compactMap { relationRows[$0].relationId }
            
            if let recommendedFeaturedRelations = document.details?.recommendedFeaturedRelations.filter({ !relationsIds.contains($0) }) {
                try await relationsService.updateRecommendedFeaturedRelations(typeId: document.objectId, relationIds: recommendedFeaturedRelations)
            }
            if let recommendedRelations = document.details?.recommendedRelations.filter({ !relationsIds.contains($0) }) {
                try await relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: recommendedRelations)
            }
            
        }
    }
}
