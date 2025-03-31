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
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private let data: RelationsSearchData
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
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
                try? await objectActionsService.updateBundledDetails(contextID: details.id, details: [ .lastUsedDate(Date.now)])
                
                data.onRelationSelect(details, false) // isNew = false
                dismiss?()
            case .new(let format):
                newRelationData = RelationInfoData(
                    name: "",
                    objectId: data.objectId,
                    spaceId: data.spaceId,
                    target: data.target,
                    mode: .create(format: format)
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
        case let .dataview(activeViewId, typeDetails):
            try await addRelationToDataview(objectId: data.objectId, relation: details, activeViewId: activeViewId, typeDetails: typeDetails)
        }
    }
    
    private func addRelationToType(relation: RelationDetails, typeData: RelationsModuleTypeData) async throws {
        switch typeData {
        case .recommendedFeaturedRelations(let details):
            var recommendedFeaturedRelations = details.recommendedFeaturedRelationsDetails
            recommendedFeaturedRelations.insert(relation, at: 0)
            
            try await relationsService
                .updateTypeRelations(
                    typeId: data.objectId,
                    recommendedRelations: details.recommendedRelationsDetails,
                    recommendedFeaturedRelations: recommendedFeaturedRelations,
                    recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
                )
        case .recommendedRelations(let details):
            var recommendedRelations = details.recommendedRelationsDetails
            recommendedRelations.insert(relation, at: 0)
            
            try await relationsService
                .updateTypeRelations(
                    typeId: data.objectId,
                    recommendedRelations: recommendedRelations,
                    recommendedFeaturedRelations: details.recommendedFeaturedRelationsDetails,
                    recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
                )
        }
    }
    
    private func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws {
        if FeatureFlags.openTypeAsSet, let typeDetails {
            try await addRelationToType(relation: relation, typeData: .recommendedRelations(typeDetails))
        } else {
            try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        }
        
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
}
