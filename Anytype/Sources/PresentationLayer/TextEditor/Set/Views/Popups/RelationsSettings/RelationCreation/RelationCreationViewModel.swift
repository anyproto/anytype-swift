import SwiftUI
import Services
import AnytypeCore


@MainActor
final class RelationCreationViewModel: ObservableObject, RelationInfoCoordinatorViewOutput {
    
    @Published var rows: [SearchDataSection<RelationSearchData>] = []
    @Published var newRelationData: RelationInfoData?
    
    var dismiss: DismissAction?
    
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
    
    func search(text: String) async {
        let propertyFormats = SupportedRelationFormat.allCases.filter {
            if text.isEmpty { return true }
            return $0.title.lowercased().contains(text.lowercased())
        }
        let existingProperties = (try? await searchService.searchRelations(text: text, excludedIds: data.excludedRelationsIds, spaceId: data.spaceId)) ?? []
        
        
        rows = .builder {
            if propertyFormats.isNotEmpty {
                SearchDataSection(
                    searchData: propertyFormats.map{ RelationSearchData.new($0) },
                    sectionName: Loc.propertiesFormats
                )
            }
            
            if existingProperties.isNotEmpty {
                SearchDataSection(
                    searchData: existingProperties.map{ RelationSearchData.existing($0) },
                    sectionName: Loc.existingProperties
                )
            }
        }
    }
    
    func onRowTap(_ row: RelationSearchData) {
        Task {
            switch row {
            case .existing(let details):
                try await onExistingPropertyTap(details)
                data.onRelationSelect(details, false) // isNew = false
            case .new(let format):
                newRelationData = RelationInfoData(
                    name: "",
                    objectId: data.objectId,
                    spaceId: data.spaceId,
                    target: data.target,
                    mode: .create
                )
            }
        }
    }
    
    // MARK: - RelationInfoCoordinatorViewOutput
    func didPressConfirm(_ relation: RelationDetails) {
        data.onRelationSelect(relation, true) // isNew = true
        dismiss?()
    }
    
    // MARK: - Private
    
    private func onExistingPropertyTap(_ details: RelationDetails) async throws {
        switch data.target {
        case let .type(data):
            try await addRelationToType(relation: details, typeData: data)
        case .dataview(let activeViewId):
            try await addRelationToDataview(objectId: data.objectId, relation: details, activeViewId: activeViewId)
        }
    }
    
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
