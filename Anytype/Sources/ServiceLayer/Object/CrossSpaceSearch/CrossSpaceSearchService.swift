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
        typeUniqueKey: String?,
        creators: [String],
        spaceId: String?,
        offset: Int,
        limit: Int
    ) async throws -> CrossSpaceSearchResult

    // Raw by-ids fetch across spaces - one batch per result page (message container
    // attribution), never per row
    func objects(ids: [String]) async throws -> [ObjectDetails]

    // Parent objects whose discussionId relation points at one of the given
    // discussion ids - resolves discussion-message containers to the object the
    // discussion is attached to (its name/icon captions the row)
    func discussionParents(discussionIds: [String]) async throws -> [ObjectDetails]
}

final class CrossSpaceSearchService: CrossSpaceSearchServiceProtocol, Sendable {

    private let crossSpaceSearchMiddleService: any CrossSpaceSearchMiddleServiceProtocol = Container.shared.crossSpaceSearchMiddleService()

    func search(
        text: String,
        layouts: [DetailsLayout],
        excludedLayouts: [DetailsLayout],
        typeUniqueKey: String?,
        creators: [String],
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
            if let typeUniqueKey {
                SearchHelper.typeUniqueKeyFilter(typeUniqueKey)
            }
            if creators.isNotEmpty {
                SearchHelper.creatorsFilter(creators)
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

    func objects(ids: [String]) async throws -> [ObjectDetails] {
        guard ids.isNotEmpty else { return [] }
        return try await crossSpaceSearchMiddleService.search(
            filters: [SearchHelper.objectsIds(ids)],
            limit: ids.count
        ).records
    }

    func discussionParents(discussionIds: [String]) async throws -> [ObjectDetails] {
        guard discussionIds.isNotEmpty else { return [] }
        return try await crossSpaceSearchMiddleService.search(
            filters: [SearchHelper.discussionIdsFilter(discussionIds)],
            limit: discussionIds.count
        ).records
    }
}
