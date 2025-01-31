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
    @Published var systemConflictRelations = [Relation]()
    
    // MARK: - Private variables
    
    let document: any BaseDocumentProtocol
    private let fieldsDataBuilder = TypeFieldsRowBuilder()
    private let moveHandler = TypeFieldsMoveHandler()
    
    private var parsedRelations = ParsedRelations.empty
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    @Injected(\.singleRelationBuilder)
    private var relationsBuilder: any SingleRelationBuilderProtocol
    
    
    // MARK: - Initializers
    
    convenience init(data: EditorTypeObject) {
        let document = Container.shared.openedDocumentProvider().document(objectId: data.objectId, spaceId: data.spaceId)
        self.init(document: document)
    }
    
    init(document: some BaseDocumentProtocol) {
        self.document = document
    }
    
    func setupSubscriptions() async {
        async let relationsSubscription: () = setupRelationsSubscription()
        async let permissionSubscription: () = setupPermissionSubscription()
        async let detailsSubscription: () = setupDetailsSubscription()
        
        (_, _, _) = await (relationsSubscription, permissionSubscription, detailsSubscription)
    }
    
    private func setupRelationsSubscription() async {
        for await relations in document.parsedRelationsPublisherForType.values {
            parsedRelations = relations
            let newRows = fieldsDataBuilder.build(
                relations: relations.sidebarRelations,
                featured: relations.featuredRelations,
                systemConflictedRelations: systemConflictRelations
            )
            
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
    
    func setupDetailsSubscription() async {
        for await details in document.detailsPublisher.values {
            try? await updateConflictRelations(details: details)
        }
    }
    
    func onRelationTap(_ data: TypeFieldsRelationRow) {
        guard let format = data.relation.format else { return }
        
        relationData = RelationInfoData(
            name: data.relation.name,
            objectId: document.objectId,
            spaceId: document.spaceId,
            target: .type(isFeatured: data.relation.isFeatured),
            mode: .edit(relationId: data.relation.id, format: format, limitedObjectTypes: data.relation.limitedObjectTypes)
        )
    }
    
    func onAddRelationTap(section: TypeFieldsSectionRow) {
        relationsSearchData = RelationsSearchData(
            objectId: document.objectId,
            spaceId: document.spaceId,
            excludedRelationsIds: relationRows.compactMap(\.relationId),
            target: .type(isFeatured: section.isHeader),
            onRelationSelect: { [spaceId = document.spaceId] details, isNew in
                AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                    format: details.format, isNew: isNew, type: .type, key: details.analyticsKey, spaceId: spaceId
                )
            }
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
            
            
            guard let format = row.relation.format?.format else {
                anytypeAssertionFailure("Empty relation format for onDeleteRelation")
                return
            }
            AnytypeAnalytics.instance().logDeleteRelation(spaceId: document.spaceId, format: format, route: .object)
        }
    }
    
    func onAddConflictRelation(_ relation: RelationDetails) {
        Task {            
            var newRecommendedRelations = parsedRelations.sidebarRelations.map(\.id)
            newRecommendedRelations.append(relation.id)
            
            try await relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: newRecommendedRelations)
            if let details = document.details { try await updateConflictRelations(details: details) }
        }
    }
    
    private func updateConflictRelations(details: ObjectDetails) async throws {
        let releationKeys = try await relationsService.getConflictRelationsForType(typeId: document.objectId, spaceId: document.spaceId)
        let allConflictRelations = relationDetailsStorage
            .relationsDetails(ids: releationKeys, spaceId: document.spaceId)
            .filter { !$0.isHidden && !$0.isDeleted }
        
        conflictRelations = allConflictRelations
            .filter { !BundledRelationKey.systemKeys.map(\.rawValue).contains($0.key) }
        
        systemConflictRelations = allConflictRelations
            .filter { BundledRelationKey.systemKeys.map(\.rawValue).contains($0.key) }
            .compactMap {
                relationsBuilder.relation(
                    relationDetails: $0,
                    details: details,
                    isFeatured: false,
                    relationValuesIsLocked: true,
                    storage: document.detailsStorage
                )
            }
        
        let newRows = fieldsDataBuilder.build(
            relations: parsedRelations.sidebarRelations,
            featured: parsedRelations.featuredRelations,
            systemConflictedRelations: systemConflictRelations
        )
        
        // do not animate on 1st appearance
        withAnimation(relationRows.isNotEmpty ? .default : nil) {
            relationRows = newRows
        }
    }
}
