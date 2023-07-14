import ProtobufMessages
import Combine
import Services
import AnytypeCore

protocol SearchServiceProtocol: AnyObject {
    func search(text: String) async throws -> [ObjectDetails]
    func search(text: String, excludedObjectIds: [String]) async throws -> [ObjectDetails]
    func searchObjectTypes(
        text: String,
        filteringTypeId: String?,
        shouldIncludeSets: Bool,
        shouldIncludeCollections: Bool,
        shouldIncludeBookmark: Bool
    ) async throws -> [ObjectDetails]
    
    func searchMarketplaceObjectTypes(text: String, includeInstalled: Bool) async throws -> [ObjectDetails]
    func searchFiles(text: String, excludedFileIds: [String]) async throws -> [ObjectDetails]
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeIds: [String]) async throws -> [ObjectDetails]
    func searchTemplates(for type: ObjectTypeId) async throws -> [ObjectDetails]
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedTypeIds: [String],
        sortRelationKey: BundledRelationKey?
    ) async throws -> [ObjectDetails]
    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String]) async throws -> [RelationOption]
    func searchRelationOptions(optionIds: [String]) async throws -> [RelationOption]
    func searchRelations(text: String, excludedIds: [String]) async throws -> [RelationDetails]
    func searchMarketplaceRelations(text: String, includeInstalled: Bool) async throws -> [RelationDetails]
    func searchArchiveObjectIds() async throws -> [String]
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    
    private enum Constants {
        static let defaultLimit = 100
    }
    
    private let accountManager: AccountManagerProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    
    init(
        accountManager: AccountManagerProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol
    ) {
        self.accountManager = accountManager
        self.objectTypeProvider = objectTypeProvider
        self.relationDetailsStorage = relationDetailsStorage
    }
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = buildFilters(isArchived: false, layouts: DetailsLayout.visibleLayouts)
        
        return try await search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func search(text: String, excludedObjectIds: [String]) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false, layouts: DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
        }
        
        return try await search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func searchObjectTypes(
        text: String,
        filteringTypeId: String? = nil,
        shouldIncludeSets: Bool,
        shouldIncludeCollections: Bool,
        shouldIncludeBookmark: Bool
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
            buildFilters(isArchived: false)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
            if let filteringTypeId {
                SearchHelper.excludedIdsFilter([filteringTypeId])
            }
        }
        
        let result = try await search(filters: filters, sorts: [sort], fullText: text)

        return result.reordered(
            by: [
                ObjectTypeId.bundled(.page).rawValue,
                ObjectTypeId.bundled(.note).rawValue,
                ObjectTypeId.bundled(.task).rawValue,
                ObjectTypeId.bundled(.collection).rawValue
            ]
        ) { $0.id }
    }
    
    func searchMarketplaceObjectTypes(text: String, includeInstalled: Bool) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = Array.builder {
            SearchHelper.workspaceId(MarketplaceId.anytypeMarketplace.rawValue)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.visibleLayouts)
            if !includeInstalled {
                SearchHelper.excludedIdsFilter(objectTypeProvider.objectTypes.map(\.sourceObject))
            }
        }
        
        return try await search(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchFiles(text: String, excludedFileIds: [String]) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.layoutFilter([DetailsLayout.file, DetailsLayout.image]),
            SearchHelper.excludedIdsFilter(excludedFileIds),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId),
        ]
        
        return try await search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeIds: [String]) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = Array.builder {
            buildFilters(isArchived: false, layouts: DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            if limitedTypeIds.isNotEmpty {
                SearchHelper.typeFilter(typeIds: limitedTypeIds)
            }
        }
                
        return try await search(filters: filters, sorts: [sort], fullText: text)
    }

    func searchTemplates(for type: ObjectTypeId) async throws -> [ObjectDetails] {
        try await search(filters: SearchHelper.templatesFilters(type: type))
    }
	
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedTypeIds: [String],
        sortRelationKey: BundledRelationKey?
    ) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: sortRelationKey ?? .lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false, layouts: DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            SearchHelper.excludedTypeFilter(excludedTypeIds)
        }
        
        return try await search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }

    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String]) async throws -> [RelationOption] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )

        var filters = buildFilters(
            isArchived: false,
            layouts: [DetailsLayout.relationOption]
        )
        filters.append(SearchHelper.relationKey(relationKey))
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        let details = try await search(filters: filters, sorts: [sort], fullText: text, limit: 0)
        return details.map { RelationOption(details: $0) }
    }

    func searchRelationOptions(optionIds: [String]) async throws -> [RelationOption] {
        var filters = buildFilters(
            isArchived: false,
            layouts: [DetailsLayout.relationOption]
        )
        filters.append(SearchHelper.supportedIdsFilter(optionIds))

        let details = try await search(filters: filters, sorts: [], fullText: "")
        return details.map { RelationOption(details: $0) }
    }
    
    func searchRelations(text: String, excludedIds: [String]) async throws -> [RelationDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            buildFilters(isArchived: false, layouts: [DetailsLayout.relation])
            SearchHelper.excludedRelationKeys(BundledRelationKey.systemKeys.map(\.rawValue))
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        let details = try await search(filters: filters, sorts: [sort], fullText: text)
        return details.map { RelationDetails(objectDetails: $0) }
    }
    
    func searchMarketplaceRelations(text: String, includeInstalled: Bool) async throws -> [RelationDetails] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = Array.builder {
            buildFilters(
                isArchived: false,
                workspaceId: MarketplaceId.anytypeMarketplace.rawValue
            )
            SearchHelper.layoutFilter([DetailsLayout.relation])
            SearchHelper.excludedRelationKeys(BundledRelationKey.systemKeys.map(\.rawValue))
            if !includeInstalled {
                SearchHelper.excludedIdsFilter(relationDetailsStorage.relationsDetails().map(\.sourceObject))
            }
        }
        let details = try await search(filters: filters, sorts: [sort], fullText: text)
        return details.map { RelationDetails(objectDetails: $0) }
    }
    
    func searchArchiveObjectIds() async throws -> [String] {
        let filters = FeatureFlags.showAllFilesInBin ? buildFilters(isArchived: true) : buildFilters(isArchived: true, layouts: DetailsLayout.visibleLayouts)
        let keys = [BundledRelationKey.id.rawValue]
        let result = try await search(filters: filters, keys: keys)
        return result.map { $0.id }
    }
}

private extension SearchService {
    
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        limit: Int = 0
    ) async throws -> [ObjectDetails] {
        let response = try await ClientCommands.objectSearch(.with {
            $0.filters = filters
            $0.sorts = sorts.map { $0.fixIncludeTime() }
            $0.fullText = fullText
            $0.limit = Int32(limit)
        }).invoke()
       
        return response.records.asDetais
    }
    
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        keys: [String] = [],
        limit: Int = 0
    ) async throws -> [ObjectDetails] {
                
        let response = try await ClientCommands.objectSearch(.with {
            $0.filters = filters
            $0.sorts = sorts.map { $0.fixIncludeTime() }
            $0.fullText = fullText
            $0.limit = Int32(limit)
            $0.keys = keys
        }).invoke()
        
        return response.records.asDetais
    }

    private func buildFilters(isArchived: Bool, workspaceId: String? = nil) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.workspaceId(workspaceId ?? accountManager.account.info.accountSpaceId),
        ]
    }
    
    private func buildFilters(isArchived: Bool, layouts: [DetailsLayout]) -> [DataviewFilter] {
        var filters = buildFilters(isArchived: isArchived)
        filters.append(SearchHelper.layoutFilter(layouts))
        return filters
    }
}
