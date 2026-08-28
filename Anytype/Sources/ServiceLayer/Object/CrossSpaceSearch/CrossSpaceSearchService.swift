import ProtobufMessages
import Services
import AnytypeCore

protocol CrossSpaceSearchServiceProtocol: AnyObject, Sendable {
    // spaceId narrows the cross-space search to one space (foreign-space scope);
    // nil searches the whole vault. Chat objects are deliberately not excluded -
    // in global mode that would hide every chat (they surface via the Chats bucket).
    func search(
        text: String,
        layouts: [DetailsLayout],
        excludedLayouts: [DetailsLayout],
        spaceId: String?,
        offset: Int,
        limit: Int
    ) async throws -> CrossSpaceSearchResult
}

final class CrossSpaceSearchService: CrossSpaceSearchServiceProtocol, Sendable {

    private let crossSpaceSearchMiddleService: any CrossSpaceSearchMiddleServiceProtocol = Container.shared.crossSpaceSearchMiddleService()

    func search(
        text: String,
        layouts: [DetailsLayout],
        excludedLayouts: [DetailsLayout],
        spaceId: String?,
        offset: Int,
        limit: Int
    ) async throws -> CrossSpaceSearchResult {

        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false)
            SearchHelper.templateScheme(include: false)
            SearchHelper.filterOutParticipantType()
            if layouts.isNotEmpty {
                SearchHelper.layoutFilter(layouts)
            }
            if excludedLayouts.isNotEmpty {
                SearchHelper.excludedLayoutFilter(excludedLayouts)
            }
            if let spaceId {
                SearchHelper.spaceIdFilter(spaceId)
            }
        }

        return try await crossSpaceSearchMiddleService.search(
            filters: filters,
            fullText: text,
            offset: offset,
            limit: limit
        )
    }
}
