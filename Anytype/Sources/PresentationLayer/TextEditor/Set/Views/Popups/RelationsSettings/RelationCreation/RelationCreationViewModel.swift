import SwiftUI
import Services
import AnytypeCore


@MainActor
final class RelationCreationViewModel: ObservableObject {
    
    @Published var rows: [SearchDataSection<RelationSearchData>] = []
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    
    private let data: RelationsSearchData
    
    init(data: RelationsSearchData) {
        self.data = data
    }
    
    func setupSubscriptions() async {
        async let subscription: () = subscribe()
        
        (_) = await (subscription)
    }
    
    // MARK: - Private
    private func subscribe() async {
        
    }
    
    func search(text: String) async {
        guard let results = try? await searchService.searchRelations(text: text, excludedIds: data.excludedRelationsIds, spaceId: data.spaceId) else {
            return
        }
        
        rows = [
            SearchDataSection(searchData: results.map{ RelationSearchData(details: $0)}, sectionName: Loc.existingProperties)
        ]
    }
    
    func onRelationTap(_ row: RelationSearchData) {
        Task {
            switch data.target {
            case let .type(data):
                try await addRelationToType(relation: row.details, typeData: data)
            case .dataview(let activeViewId):
                try await addRelationToDataview(objectId: data.objectId, relation: row.details, activeViewId: activeViewId)
            }
            
            data.onRelationSelect(row.details, false) // isNew = false
        }
    }
    
    // MARK: - Private
    
    private func addRelationToType(relation: RelationDetails, typeData: RelationsModuleTypeData) async throws {
        switch typeData {
        case .recommendedFeaturedRelations(var relationIds):
            relationIds.insert(relation.id, at: 0)
            try await relationsService.updateRecommendedFeaturedRelations(typeId: data.objectId, relationIds: relationIds)
        case .recommendedRelations(var relationIds):
            relationIds.insert(relation.id, at: 0)
            try await relationsService.updateRecommendedRelations(typeId: data.objectId, relationIds: relationIds)
        }
    }
    
    private func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws {
        try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
}
