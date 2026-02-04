import SwiftUI
import Services
import AnytypeCore


@MainActor
@Observable
final class PropertyCreationViewModel: PropertyInfoCoordinatorViewOutput {

    var rows: [SearchDataSection<PropertySearchData>] = []
    var newPropertyData: PropertyInfoData?

    @ObservationIgnored
    var dismiss: DismissAction?

    @ObservationIgnored
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @ObservationIgnored
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    @ObservationIgnored
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    @ObservationIgnored
    private let data: PropertiesSearchData
    @ObservationIgnored
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    init(data: PropertiesSearchData) {
        self.data = data
    }
    
    func search(text: String) async {
        let propertyFormats = SupportedPropertyFormat.allCases.filter {
            if text.isEmpty { return true }
            return $0.title.lowercased().contains(text.lowercased())
        }
        let existingProperties = (try? await searchService.searchRelations(text: text, excludedIds: data.excludedRelationsIds, spaceId: data.spaceId)) ?? []
        
        
        rows = .builder {
            if propertyFormats.isNotEmpty {
                SearchDataSection(
                    searchData: propertyFormats.map{ PropertySearchData.new($0) },
                    sectionName: Loc.propertiesFormats
                )
            }
            
            if existingProperties.isNotEmpty {
                SearchDataSection(
                    searchData: existingProperties.map{ PropertySearchData.existing($0) },
                    sectionName: Loc.existingProperties
                )
            }
        }
    }
    
    func onRowTap(_ row: PropertySearchData) {
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
                    mode: .create(format: format),
                    isReadOnly: false
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
            mode: .create(format: .text),
            isReadOnly: false
        )
    }
    
    // MARK: - PropertyInfoCoordinatorViewOutput
    func didPressConfirm(_ relation: PropertyDetails) {
        data.onRelationSelect(relation, true) // isNew = true
        dismiss?()
    }
    
    // MARK: - Private
    
    private func onExistingPropertyTap(_ details: PropertyDetails) async throws {
        switch data.target {
        case let .type(data):
            try await addPropertyToType(relation: details, typeData: data)
        case let .dataview(objectId, activeViewId, typeDetails):
            try await addPropertyToDataview(objectId: objectId, relation: details, activeViewId: activeViewId, typeDetails: typeDetails)
        case .object(let objectId):
            try await addPropertyToObject(objectId: objectId, relation: details)
        case .library:
            anytypeAssertionFailure("Unsupported call of \(#function) for target .library")
        }
    }
    
    private func addPropertyToType(relation: PropertyDetails, typeData: PropertiesModuleTypeData) async throws {
        switch typeData {
        case .recommendedFeaturedRelations(let type):
            try await propertiesService.addTypeFeaturedRecommendedProperty(type: type, property: relation)
        case .recommendedRelations(let type):
            try await propertiesService.addTypeRecommendedProperty(type: type, property: relation)
        }
    }
    
    private func addPropertyToDataview(objectId: String, relation: PropertyDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws {
        if let typeDetails {
            let type = ObjectType(details: typeDetails)
            try await addPropertyToType(relation: relation, typeData: .recommendedRelations(type))
        } else {
            try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        }
        
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
    
    
    func addPropertyToObject(objectId: String, relation: PropertyDetails) async throws {
        try await propertiesService.addProperties(objectId: objectId, propertiesDetails: [relation])
    }
}
