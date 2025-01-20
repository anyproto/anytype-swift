import Foundation
import Services
import SwiftProtobuf
import AnytypeCore
import Combine
import SwiftUI


@MainActor
final class TypeFieldsViewModel: ObservableObject {
        
    @Published var canEditRelationsList = false
    @Published var showConflictingInfo = false
    @Published var relationRows = [TypeFieldsRow]()
    @Published var relationsSearchData: RelationsSearchData?
    @Published var relationData: RelationInfoData?
    @Published var conflictRelations = [RelationDetails]()
    
    // MARK: - Private variables
    
    let document: any BaseDocumentProtocol
    private let fieldsDataBuilder = TypeFieldsRowBuilder()
    private let moveHandler = TypeFieldsMoveHandler()
    
    private var parsedRelations = ParsedRelations.empty
    
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
    
    func onAppear() {
        Task { try await updateConflictRelations() }
    }
    
    func setupSubscriptions() async {
        async let relationsSubscription: () = setupRelationsSubscription()
        async let permissionSubscription: () = setupPermissionSubscription()
        
        (_, _) = await (relationsSubscription, permissionSubscription)
    }
    
    private func setupRelationsSubscription() async {
        for await relations in document.parsedRelationsPublisherForType.values {
            parsedRelations = relations
            let newRows = fieldsDataBuilder.build(relations: relations.sidebarRelations, featured: relations.featuredRelations)
            
            // do not animate on 1st appearance
            withAnimation(relationRows.isNotEmpty ? .default : nil) {
                relationRows = newRows
            }
        }
    }
    
    private func setupPermissionSubscription() async {
        for await permissions in document.permissionsPublisher.values {
            canEditRelationsList = permissions.canEditRelationsList
        }
    }
    
    func onRelationTap(_ data: TypeFieldsRelationRow) {
        guard let format = data.relation.format else { return }
        
        relationData = RelationInfoData(
            name: data.relation.name,
            objectId: document.objectId,
            spaceId: document.spaceId,
            target: .type(isFeatured: data.relation.isFeatured),
            mode: .edit(relationId: data.relation.id, format: format)
        )
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
    
    func onDeleteRelation(_ row: TypeFieldsRelationRow) {
        Task {
            let relationsId = row.relation.id
            
            if let recommendedFeaturedRelations = document.details?.recommendedFeaturedRelations.filter({ relationsId != $0 }) {
                try await relationsService.updateRecommendedFeaturedRelations(typeId: document.objectId, relationIds: recommendedFeaturedRelations)
            }
            if let recommendedRelations = document.details?.recommendedRelations.filter({ relationsId != $0 }) {
                try await relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: recommendedRelations)
            }
            
        }
    }
    
    func onAddConflictRelation(_ relation: RelationDetails) {
        Task {            
            var newRecommendedRelations = parsedRelations.sidebarRelations.map(\.id)
            newRecommendedRelations.append(relation.id)
            
            try await relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: newRecommendedRelations)
            try await updateConflictRelations()
        }
    }
    
    private func updateConflictRelations() async throws {
        let releationKeys = try await relationsService.getConflictRelationsForType(typeId: document.objectId, spaceId: document.spaceId)
        conflictRelations = relationDetailsStorage
            .relationsDetails(ids: releationKeys, spaceId: document.spaceId)
            .filter { !$0.isHidden && !$0.isDeleted }
    }
}
