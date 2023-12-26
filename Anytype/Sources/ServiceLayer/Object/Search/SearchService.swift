import ProtobufMessages
import Combine
import Services
import AnytypeCore

protocol SearchServiceProtocol: AnyObject {
    func search(text: String, spaceId: String) async throws -> [ObjectDetails]
    func search(text: String, excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails]
    func searchObjectTypes(
        text: String,
        filteringTypeId: String?,
        shouldIncludeSets: Bool,
        shouldIncludeCollections: Bool,
        shouldIncludeBookmark: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails]
    
    func searchMarketplaceObjectTypes(text: String, excludedIds: [String]) async throws -> [ObjectDetails]
    func searchFiles(text: String, excludedFileIds: [String],  spaceId: String) async throws -> [ObjectDetails]
    func searchImages() async throws -> [ObjectDetails]
    func searchObjectsByTypes(text: String, typeIds: [String], excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails]
    func searchTemplates(for type: String, spaceId: String) async throws -> [ObjectDetails]
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout],
        spaceId: String,
        sortRelationKey: BundledRelationKey?
    ) async throws -> [ObjectDetails]
    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String], spaceId: String) async throws -> [RelationOption]
    func searchRelationOptions(optionIds: [String], spaceId: String) async throws -> [RelationOption]
    func searchRelations(text: String, excludedIds: [String], spaceId: String) async throws -> [RelationDetails]
    func searchMarketplaceRelations(text: String, excludedIds: [String]) async throws -> [RelationDetails]
    func searchArchiveObjectIds(spaceId: String) async throws -> [String]
    func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], spaceId: String) async throws -> [ObjectDetails]
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    
    private enum Constants {
        static let defaultLimit = 100
    }
    
    private let accountManager: AccountManagerProtocol
    private let searchMiddleService: SearchMiddleServiceProtocol
    
    init(accountManager: AccountManagerProtocol, searchMiddleService: SearchMiddleServiceProtocol) {
        self.accountManager = accountManager
        self.searchMiddleService = searchMiddleService
    }
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String, spaceId: String) async throws -> [ObjectDetails] {
        try await searchObjectsWithLayouts(text: text, layouts: DetailsLayout.visibleLayouts, spaceId: spaceId)
    }
    
    func search(text: String, excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let spaceIds = [spaceId, accountManager.account.info.techSpaceId]
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false, spaceIds: spaceIds, layouts: DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
        }
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func searchObjectTypes(
        text: String,
        filteringTypeId: String? = nil,
        shouldIncludeSets: Bool,
        shouldIncludeCollections: Bool,
        shouldIncludeBookmark: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
                
        var layouts = DetailsLayout.visibleLayouts
        
        if !shouldIncludeSets {
            layouts.removeAll(where: { $0 == .set })
        }
        
        if !shouldIncludeCollections {
            layouts.removeAll(where: { $0 == .collection })
        }
        
        if !shouldIncludeBookmark {
            layouts.removeAll(where: { $0 == .bookmark })
        }
        
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false, spaceId: spaceId)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
            if let filteringTypeId {
                SearchHelper.excludedIdsFilter([filteringTypeId])
            }
        }
        
        let result = try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)

        return result.reordered(
            by: [
                ObjectTypeUniqueKey.page.value,
                ObjectTypeUniqueKey.note.value,
                ObjectTypeUniqueKey.task.value,
                ObjectTypeUniqueKey.collection.value
            ]
        ) { $0.uniqueKey }
    }
    
    func searchMarketplaceObjectTypes(text: String, excludedIds: [String]) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = Array.builder {
            SearchHelper.spaceId(MarketplaceId.anytypeMarketplace.rawValue)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchFiles(text: String, excludedFileIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.layoutFilter([DetailsLayout.file, DetailsLayout.image]),
            SearchHelper.excludedIdsFilter(excludedFileIds),
            SearchHelper.spaceId(spaceId),
        ]
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func searchImages() async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.id,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.layoutFilter([DetailsLayout.image])
        ]
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: "", limit: Constants.defaultLimit)
    }
    
    func searchObjectsByTypes(text: String, typeIds: [String], excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        let spaceIds = [spaceId, accountManager.account.info.techSpaceId]
        let filters: [DataviewFilter] = .builder {
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            if typeIds.isEmpty {
                buildFilters(isArchived: false, spaceIds: spaceIds, layouts: DetailsLayout.visibleLayouts)
            } else {
                buildFilters(isArchived: false, spaceIds: spaceIds)
                SearchHelper.typeFilter(typeIds: typeIds)
            }
        }
                
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
    }

    func searchTemplates(for type: String, spaceId: String) async throws -> [ObjectDetails] {
        try await searchMiddleService.search(filters: SearchHelper.templatesFilters(type: type, spaceId: spaceId))
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
        let spaceIds = [spaceId, accountManager.account.info.techSpaceId]
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false, spaceIds: spaceIds, layouts: DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            SearchHelper.excludedLayoutFilter(excludedLayouts)
        }
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }

    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String], spaceId: String) async throws -> [RelationOption] {
        var filters = buildFilters(
            isArchived: false,
            spaceId: spaceId,
            layouts: [DetailsLayout.relationOption]
        )
        filters.append(SearchHelper.relationKey(relationKey))
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        let details = try await searchMiddleService.search(filters: filters, sorts: [], fullText: text, limit: 0)
        return details.map { RelationOption(details: $0) }
    }

    func searchRelationOptions(optionIds: [String], spaceId: String) async throws -> [RelationOption] {
        var filters = buildFilters(
            isArchived: false,
            spaceId: spaceId,
            layouts: [DetailsLayout.relationOption]
        )
        filters.append(SearchHelper.supportedIdsFilter(optionIds))

        let details = try await searchMiddleService.search(filters: filters, sorts: [], fullText: "")
        return details.map { RelationOption(details: $0) }
    }
    
    func searchRelations(text: String, excludedIds: [String], spaceId: String) async throws -> [RelationDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false,  spaceId: spaceId, layouts: [DetailsLayout.relation])
            SearchHelper.relationReadonlyValue(false)
            SearchHelper.excludedRelationKeys(BundledRelationKey.internalKeys.map(\.rawValue))
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        let details = try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
        return details.map { RelationDetails(objectDetails: $0) }
    }
    
    func searchMarketplaceRelations(text: String, excludedIds: [String]) async throws -> [RelationDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            buildFilters(
                isArchived: false,
                spaceId: MarketplaceId.anytypeMarketplace.rawValue
            )
            SearchHelper.layoutFilter([DetailsLayout.relation])
            SearchHelper.relationReadonlyValue(false)
            SearchHelper.excludedRelationKeys(BundledRelationKey.internalKeys.map(\.rawValue))
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        let details = try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
        return details.map { RelationDetails(objectDetails: $0) }
    }
    
    func searchArchiveObjectIds(spaceId: String) async throws -> [String] {
        let filters = buildFilters(isArchived: true, spaceId: spaceId)
        let keys = [BundledRelationKey.id.rawValue]
        let result = try await searchMiddleService.search(filters: filters, keys: keys)
        return result.map { $0.id }
    }
    
    func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let spaceIds = [spaceId, accountManager.account.info.techSpaceId]
        let filters = buildFilters(isArchived: false, spaceIds: spaceIds, layouts: layouts)
        
        return try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
}

private extension SearchService {
    
    private func buildFilters(isArchived: Bool, spaceIds: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.spaceIds(spaceIds)
        ]
    }
    
    private func buildFilters(isArchived: Bool, spaceId: String) -> [DataviewFilter] {
        buildFilters(isArchived: isArchived, spaceIds: [spaceId])
    }
    
    private func buildFilters(isArchived: Bool, spaceIds: [String], layouts: [DetailsLayout]) -> [DataviewFilter] {
        var filters = buildFilters(isArchived: isArchived, spaceIds: spaceIds)
        filters.append(SearchHelper.layoutFilter(layouts))
        filters.append(SearchHelper.templateScheme(include: false))
        return filters
    }
    
    private func buildFilters(isArchived: Bool, spaceId: String, layouts: [DetailsLayout]) -> [DataviewFilter] {
        buildFilters(isArchived: isArchived, spaceIds: [spaceId], layouts: layouts)
    }
}
