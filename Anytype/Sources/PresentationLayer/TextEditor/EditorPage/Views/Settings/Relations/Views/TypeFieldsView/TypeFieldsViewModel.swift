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
    @Published var relationRows = [TypeFieldsRelationsData]()
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
    
    func onAddRelationTap(section: TypeFieldsRelationsSection) {
        relationsSearchData = RelationsSearchData(
            objectId: document.objectId,
            spaceId: document.spaceId,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
            target: .object,
            onRelationSelect: { [weak self] details, isNew in
                guard let self else { return }
                addRelation(details, section: section)
            }
        )
    }
    
    func onDeleteRelations(_ indexes: IndexSet) {
        Task {
            let relationsIds = indexes.compactMap { relationRows[$0].relationId }
            
            if let recommendedFeaturedRelations = document.details?.recommendedFeaturedRelations.filter({ !relationsIds.contains($0) }) {
                try await relationsService.updateRecommendedFeaturedRelations(objectId: document.objectId, relationIds: recommendedFeaturedRelations)
            }
            if let recommendedRelations = document.details?.recommendedRelations.filter({ !relationsIds.contains($0) }) {
                try await relationsService.updateRecommendedRelations(objectId: document.objectId, relationIds: recommendedRelations)
            }
            
        }
    }
    
    private func addRelation(_ details: RelationDetails, section: TypeFieldsRelationsSection) {
        Task {
            switch section {
            case .header:
                var relationIds = document.details?.recommendedFeaturedRelations ?? []
                relationIds.insert(details.id, at: 0)
                try await relationsService.updateRecommendedFeaturedRelations(objectId: document.objectId, relationIds: relationIds)
            case .fieldsMenu:
                var relationIds = document.details?.recommendedRelations ?? []
                relationIds.insert(details.id, at: 0)
                try await self.relationsService.updateRecommendedRelations(objectId: self.document.objectId, relationIds: relationIds)
            }
        }
    }
}
