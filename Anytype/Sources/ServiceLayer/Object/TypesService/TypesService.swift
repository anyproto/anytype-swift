import ProtobufMessages
import SwiftProtobuf
import Services
import AnytypeCore


final class TypesService: TypesServiceProtocol, Sendable {
    
    private let searchMiddleService: any SearchMiddleServiceProtocol = Container.shared.searchMiddleService()
    private let actionsService: any ObjectActionsServiceProtocol = Container.shared.objectActionsService()
    private let pinsStorage: any TypesPinStorageProtocol = Container.shared.typesPinsStorage()
    private let typeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    
    func createType(name: String, pluralName: String, icon: CustomIcon?, color: CustomIconColor?, spaceId: String) async throws -> ObjectType {
        var fields: [String: Google_Protobuf_Value] = [
            BundledPropertyKey.name.rawValue: name.protobufValue,
            BundledPropertyKey.pluralName.rawValue: pluralName.protobufValue
        ]
        
        if let icon = icon {
            fields[BundledPropertyKey.iconName.rawValue] = icon.stringRepresentation.protobufValue
        }
        
        if let color = color {
            fields[BundledPropertyKey.iconOption.rawValue] = color.iconOption.protobufValue
        }
        
        let details = Google_Protobuf_Struct(fields: fields)
        
        let result = try await ClientCommands.objectCreateObjectType(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        
        let objectDetails = try ObjectDetails(protobufStruct: result.details)
        return ObjectType(details: objectDetails)
    }
    
    func deleteType(typeId: String, spaceId: String) async throws {
        try await actionsService.delete(objectIds: [typeId])
        try pinsStorage.removePin(typeId: typeId, spaceId: spaceId)
    }
    
    // MARK: - Search
    func searchObjectTypes(
        text: String,
        includePins: Bool,
        includeLists: Bool,
        includeBookmarks: Bool,
        includeFiles: Bool,
        includeChat: Bool,
        includeTemplates: Bool,
        incudeNotForCreation: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails] {
        let excludedTypeIds = includePins ? [] : try await searchPinnedTypes(text: "", spaceId: spaceId).map { $0.id }
        
        let sort = SearchHelper.defaultObjectTypeSort(isChat: workspaceStorage.spaceIsChat(spaceId: spaceId))
                
        var layouts = includeFiles ? DetailsLayout.visibleLayoutsWithFiles : DetailsLayout.visibleLayouts
        
        if !includeLists {
            layouts.removeAll(where: { $0.isList })
        }
        
        if !includeBookmarks {
            layouts.removeAll(where: { $0 == .bookmark })
        }
        
        if !includeChat {
            layouts.removeAll(where: { $0 == .chatDerived })
        }
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
            SearchHelper.excludedIdsFilter(excludedTypeIds)
            if !incudeNotForCreation {
                SearchHelper.excludeObjectRestriction(.createObjectOfThisType)
            }
            if !includeTemplates {
                SearchHelper.uniqueKeyFilter(key: ObjectTypeUniqueKey.template.value, include: false)
            }
        }
        
        let result = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: sort, fullText: text)

        return result
    }
    
    func searchListTypes(
        text: String,
        includePins: Bool,
        spaceId: String
    ) async throws -> [ObjectType] {
        let excludedTypeIds = includePins ? [] : try await searchPinnedTypes(text: "", spaceId: spaceId).map { $0.id }
        
        let sort = SearchHelper.defaultObjectTypeSort(isChat: workspaceStorage.spaceIsChat(spaceId: spaceId))
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.listLayouts)
            SearchHelper.excludedIdsFilter(excludedTypeIds)
        }
        
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: sort, fullText: text)
            .map { ObjectType(details: $0) }
    }
    
    func searchLibraryObjectTypes(text: String, includeInstalledTypes: Bool, spaceId: String) async throws -> [ObjectDetails] {
        let excludedIds = includeInstalledTypes ? [] : typeProvider.objectTypes(spaceId: spaceId).map(\.sourceObject)
        
        let sort = SearchHelper.defaultObjectTypeSort(isChat: workspaceStorage.spaceIsChat(spaceId: spaceId))
        
        let filters = Array.builder {
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        return try await searchMiddleService.search(spaceId: MarketplaceId.anytypeLibrary.rawValue, filters: filters, sorts: sort, fullText: text)
    }
    
    func searchPinnedTypes(text: String, spaceId: String) async throws -> [ObjectType] {
        return try pinsStorage.getPins(spaceId: spaceId)
            .filter {
                guard text.isNotEmpty else { return true }
                return $0.name.lowercased().contains(text.lowercased())
            }
    }
    
    func addPinedType(_ type: ObjectType, spaceId: String) throws {
        try pinsStorage.appendPin(type, spaceId: spaceId)
    }
    
    func removePinedType(typeId: String, spaceId: String) throws {
        try pinsStorage.removePin(typeId: typeId, spaceId: spaceId)
    }
    
    func getPinnedTypes(spaceId: String) throws -> [ObjectType] {
        try pinsStorage.getPins(spaceId: spaceId)
    }
}
