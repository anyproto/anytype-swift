import ProtobufMessages
import Services
import AnytypeCore

protocol SearchWithMetaServiceProtocol: AnyObject, Sendable {
    func search(
        text: String,
        spaceId: String,
        layouts: [DetailsLayout],
        sorts: [DataviewSort],
        excludedObjectIds: [String]
    ) async throws -> [SearchResultWithMeta]
}

final class SearchWithMetaService: SearchWithMetaServiceProtocol, Sendable {

    private let searchWithMetaMiddleService: any SearchWithMetaMiddleServiceProtocol = Container.shared.searchWithMetaMiddleService()
    private let spaceViewsStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()

    // MARK: - SearchServiceProtocol

    func search(
        text: String,
        spaceId: String,
        layouts: [DetailsLayout],
        sorts: [DataviewSort],
        excludedObjectIds: [String]
    ) async throws -> [SearchResultWithMeta] {

        let spaceType = spaceViewsStorage.spaceView(spaceId: spaceId)?.spaceType
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: layouts, spaceType: spaceType)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
        }

        return try await searchWithMetaMiddleService.search(spaceId: spaceId, filters: filters, sorts: sorts, fullText: text, limit: SearchDefaults.objectsLimit)
    }
}
