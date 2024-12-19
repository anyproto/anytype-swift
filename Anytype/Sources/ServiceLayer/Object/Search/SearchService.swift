import ProtobufMessages
import Services
import AnytypeCore


enum SearchDefaults {
    static let objectsLimit = 100
}

final class SearchService: SearchServiceProtocol, Sendable {
    
    private let searchMiddleService: any SearchMiddleServiceProtocol = Container.shared.searchMiddleService()
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String, spaceId: String) async throws -> [ObjectDetails] {
        try await searchObjectsWithLayouts(text: text, layouts: DetailsLayout.visibleLayouts, spaceId: spaceId)
    }
    
    func searchFiles(text: String, excludedFileIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter(DetailsLayout.fileAndMediaLayouts)
            SearchHelper.excludedIdsFilter(excludedFileIds)
        }
        
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text, limit: SearchDefaults.objectsLimit)
    }
    
    func searchImages(spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.id,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter([DetailsLayout.image])
        }
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: "", limit: SearchDefaults.objectsLimit)
    }
    
    func search(text: String, spaceId: String, limitObjectIds: [String]) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        let filters: [DataviewFilter] = .builder {
            SearchHelper.includeIdsFilter(limitObjectIds)
            SearchHelper.notHiddenFilters()
        }
                
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchObjects(spaceId: String, objectIds: [String]) async throws -> [ObjectDetails] {
        let filters: [DataviewFilter] = .builder {
            SearchHelper.includeIdsFilter(objectIds)
        }
                
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, limit: 0)
    }
    
    func searchObjectsByTypes(text: String, typeIds: [String], excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        let filters: [DataviewFilter] = .builder {
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            if typeIds.isEmpty {
                SearchFiltersBuilder.build(isArchived: false, layouts: DetailsLayout.visibleLayouts)
            } else {
                SearchFiltersBuilder.build(isArchived: false)
                SearchHelper.typeFilter(typeIds)
            }
        }
                
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)
    }

    func searchTemplates(for type: String, spaceId: String) async throws -> [ObjectDetails] {
        try await searchMiddleService.search(spaceId: spaceId, filters: SearchHelper.templatesFilters(type: type))
    }
	
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout],
        spaceId: String,
        sortRelationKey: BundledRelationKey?
    ) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: sortRelationKey ?? .lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: DetailsLayout.visibleLayoutsWithFiles)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            SearchHelper.excludedLayoutFilter(excludedLayouts)
        }
        
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text, limit: SearchDefaults.objectsLimit)
    }

    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String], spaceId: String) async throws -> [RelationOption] {
        var filters = SearchFiltersBuilder.build(
            isArchived: false,
            layouts: [DetailsLayout.relationOption]
        )
        filters.append(SearchHelper.relationKey(relationKey))
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let details = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text, limit: 0)
        return details.map { RelationOption(details: $0) }
    }

    func searchRelationOptions(optionIds: [String], spaceId: String) async throws -> [RelationOption] {
        var filters = SearchFiltersBuilder.build(
            isArchived: false,
            layouts: [DetailsLayout.relationOption]
        )
        filters.append(SearchHelper.includeIdsFilter(optionIds))

        let details = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [], fullText: "")
        return details.map { RelationOption(details: $0) }
    }
    
    func searchRelations(text: String, excludedIds: [String], spaceId: String) async throws -> [RelationDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: [DetailsLayout.relation])
            SearchHelper.relationReadonlyValue(false)
            SearchHelper.excludedRelationKeys(BundledRelationKey.internalKeys.map(\.rawValue))
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        let details = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)
        return details.map { RelationDetails(details: $0) }
    }
    
    func searchLibraryRelations(text: String, excludedIds: [String]) async throws -> [RelationDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false)
            SearchHelper.layoutFilter([DetailsLayout.relation])
            SearchHelper.relationReadonlyValue(false)
            SearchHelper.excludedRelationKeys(BundledRelationKey.internalKeys.map(\.rawValue))
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        let details = try await searchMiddleService.search(spaceId: MarketplaceId.anytypeLibrary.rawValue, filters: filters, sorts: [sort], fullText: text)
        return details.map { RelationDetails(details: $0) }
    }
    
    func searchArchiveObjectIds(spaceId: String) async throws -> [String] {
        let filters = SearchFiltersBuilder.build(isArchived: true)
        let keys = [BundledRelationKey.id.rawValue]
        let result = try await searchMiddleService.search(spaceId: spaceId, filters: filters, keys: keys)
        return result.map { $0.id }
    }
    
    func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = SearchFiltersBuilder.build(isArchived: false, layouts: layouts)
        
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text, limit: SearchDefaults.objectsLimit)
    }
    
    func searchAll(text: String, spaceId: String) async throws -> [ObjectDetails] {
        let filters = SearchFiltersBuilder.build(isArchived: false)
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, fullText: text)
    }
}
