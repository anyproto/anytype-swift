import ProtobufMessages
import SwiftProtobuf
import Services


final class TypesService: TypesServiceProtocol {
    
    private let searchMiddleService: SearchMiddleServiceProtocol
    private let typeProvider: ObjectTypeProviderProtocol
    
    init(
        searchMiddleService: SearchMiddleServiceProtocol,
        typeProvider: ObjectTypeProviderProtocol
    ) {
        self.searchMiddleService = searchMiddleService
        self.typeProvider = typeProvider
    }
    
    func createType(name: String, spaceId: String) async throws -> ObjectType {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue,
            ]
        )
        
        let result = try await ClientCommands.objectCreateObjectType(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        
        let objectDetails = try ObjectDetails(protobufStruct: result.details)
        return ObjectType(details: objectDetails)
    }
    
    // MARK: - Search
    func searchObjectTypes(
        text: String,
        shouldIncludeLists: Bool,
        shouldIncludeBookmark: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastUsedDate,
            type: .desc
        )
                
        var layouts = DetailsLayout.visibleLayouts
        
        if !shouldIncludeLists {
            layouts.removeAll(where: { $0 == .set })
            layouts.removeAll(where: { $0 == .collection })
        }
        
        if !shouldIncludeBookmark {
            layouts.removeAll(where: { $0 == .bookmark })
        }
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, spaceId: spaceId)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
        }
        
        let result = try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)

        return result
    }
    
    func searchListTypes(text: String, spaceId: String) async throws -> [ObjectType] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastUsedDate,
            type: .desc
        )
                
        let layouts: [DetailsLayout] = [.set, .collection]
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, spaceId: spaceId)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
        }
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
            .map { ObjectType(details: $0) }
    }
    
    func searchLibraryObjectTypes(text: String, excludedIds: [String]) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = Array.builder {
            SearchHelper.spaceId(MarketplaceId.anytypeLibrary.rawValue)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchPinnedTypes(text: String, spaceId: String) async throws -> [ObjectType] {
        let page = try typeProvider.objectType(uniqueKey: .page, spaceId: spaceId)
        let note = try typeProvider.objectType(uniqueKey: .note, spaceId: spaceId)
        let task = try typeProvider.objectType(uniqueKey: .task, spaceId: spaceId)
        return [ note, page, task ]
    }
}
