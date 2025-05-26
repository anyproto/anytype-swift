import SwiftUI
import Services
import AnytypeCore


@MainActor
final class RelationCreationViewModel: ObservableObject, PropertyInfoCoordinatorViewOutput {
    
    @Published var rows: [SearchDataSection<RelationSearchData>] = []
    @Published var newPropertyData: PropertyInfoData?
    
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
                newPropertyData = PropertyInfoData(
                    name: "",
                    objectId: data.objectId,
                    spaceId: data.spaceId,
                    target: data.target,
                    mode: .create(format: format)
                )
            }
        }
    }
    
    func onNewPropertyTap(name: String) {
        newPropertyData = PropertyInfoData(
            name: name,
            objectId: data.objectId,
            spaceId: data.spaceId,
            target: data.target,
            mode: .create(format: .text)
        )
    }
    
    // MARK: - PropertyInfoCoordinatorViewOutput
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
        case .object(let objectId):
            try await addRelationToObject(objectId: objectId, relation: details)
        case .library:
            anytypeAssertionFailure("Unsupported call of \(#function) for target .library")
        }
    }
    
    private func addRelationToType(relation: RelationDetails, typeData: RelationsModuleTypeData) async throws {
        switch typeData {
        case .recommendedFeaturedRelations(let type):
            try await relationsService.addTypeFeaturedRecommendedRelation(type: type, relation: relation)
        case .recommendedRelations(let type):
            try await relationsService.addTypeRecommendedRelation(type: type, relation: relation)
        }
    }
    
    private func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws {
        if let typeDetails {
            let type = ObjectType(details: typeDetails)
            try await addRelationToType(relation: relation, typeData: .recommendedRelations(type))
        } else {
            try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        }
        
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
    
    
    func addRelationToObject(objectId: String, relation: RelationDetails) async throws {
        try await relationsService.addRelations(objectId: objectId, relationsDetails: [relation])
    }
}
