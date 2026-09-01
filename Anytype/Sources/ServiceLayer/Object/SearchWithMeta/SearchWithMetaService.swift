import ProtobufMessages
import Services
import AnytypeCore

protocol SearchWithMetaServiceProtocol: AnyObject, Sendable {
    func search(
        text: String,
        spaceId: String,
        layouts: [DetailsLayout],
        excludedLayouts: [DetailsLayout],
        typeUniqueKey: String?,
        creators: [String],
        sorts: [DataviewSort],
        excludedObjectIds: [String],
        offset: Int
    ) async throws -> [SearchResultWithMeta]
}

extension SearchWithMetaServiceProtocol {
    func search(
        text: String,
        spaceId: String,
        layouts: [DetailsLayout],
        sorts: [DataviewSort],
        excludedObjectIds: [String]
    ) async throws -> [SearchResultWithMeta] {
        try await search(
            text: text,
            spaceId: spaceId,
            layouts: layouts,
            excludedLayouts: [],
            typeUniqueKey: nil,
            creators: [],
            sorts: sorts,
            excludedObjectIds: excludedObjectIds,
            offset: 0
        )
    }
}

final class SearchWithMetaService: SearchWithMetaServiceProtocol, Sendable {

    private let searchWithMetaMiddleService: any SearchWithMetaMiddleServiceProtocol = Container.shared.searchWithMetaMiddleService()
    private let spaceViewsStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()

    // MARK: - SearchServiceProtocol

    func search(
        text: String,
        spaceId: String,
        layouts: [DetailsLayout],
        excludedLayouts: [DetailsLayout],
        typeUniqueKey: String?,
        creators: [String],
        sorts: [DataviewSort],
        excludedObjectIds: [String],
        offset: Int
    ) async throws -> [SearchResultWithMeta] {

        let spaceType = spaceViewsStorage.spaceView(spaceId: spaceId)?.spaceType
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: layouts, spaceType: spaceType)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
            if excludedLayouts.isNotEmpty {
                SearchHelper.excludedLayoutFilter(excludedLayouts)
            }
            if let typeUniqueKey {
                SearchHelper.typeUniqueKeyFilter(typeUniqueKey)
            }
            if creators.isNotEmpty {
                SearchHelper.creatorsFilter(creators)
            }
        }

        return try await searchWithMetaMiddleService.search(spaceId: spaceId, filters: filters, sorts: sorts, fullText: text, offset: offset, limit: SearchDefaults.objectsLimit)
    }
}
