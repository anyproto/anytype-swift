import Services
import AnytypeCore

protocol MentionObjectsServiceProtocol: AnyObject, Sendable {
    func searchMentions(spaceId: String, text: String, excludedObjectIds: [String], limitLayout: [DetailsLayout]) async throws -> [MentionObject]
    func searchMentionById(spaceId: String, objectId: String) async throws -> MentionObject
}

final class MentionObjectsService: MentionObjectsServiceProtocol, Sendable {

    private let searchMiddleService: any SearchMiddleServiceProtocol = Container.shared.searchMiddleService()
    private let spaceViewsStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()

    func searchMentions(spaceId: String, text: String, excludedObjectIds: [String], limitLayout: [DetailsLayout]) async throws -> [MentionObject] {
        let sort = SearchHelper.sort(
            relation: .lastOpenedDate,
            type: .desc
        )

        let spaceUxType = spaceViewsStorage.spaceView(spaceId: spaceId)?.uxType
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: limitLayout, spaceUxType: spaceUxType)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
        }

        let details = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)

        return details.map { MentionObject(details: $0) }
    }
    
    func searchMentionById(spaceId: String, objectId: String) async throws -> MentionObject {
        let filters: [DataviewFilter] = .builder {
            SearchHelper.objectsIds([objectId])
        }
        
        let details = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [], fullText: "", limit: 1)
        guard let first = details.first else {
            anytypeAssertionFailure("Mention object not found")
            throw CommonError.undefined
        }
        return MentionObject(details: first)
    }
}
