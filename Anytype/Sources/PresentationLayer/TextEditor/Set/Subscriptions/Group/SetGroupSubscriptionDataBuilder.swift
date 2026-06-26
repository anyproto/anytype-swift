import Foundation
import Services
import AnytypeCore

@MainActor
protocol SetGroupSubscriptionDataBuilderProtocol {

    var groupSubscriptionId: String { get }

    func groupsData(_ setDocument: some SetDocumentProtocol) -> GroupsSubscriptionData
}

@MainActor
final class SetGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilderProtocol {

    let groupSubscriptionId = "Set.Groups-\(UUID().uuidString)"

    @Injected(\.participantsStorage)
    private var participantsStorage: any ParticipantsStorageProtocol

    nonisolated init() {}

    func groupsData(_ setDocument: some SetDocumentProtocol) -> GroupsSubscriptionData {
        let participantId = participantsStorage.participants
            .first { $0.spaceId == setDocument.spaceId }?.id
        var filters = setDocument.activeView.filters
            .enrichingFormats(with: setDocument.dataViewRelationsDetails)
            .removingUnsupportedFilters()
            .resolvingCurrentUserPlaceholder(participantId: participantId)
        filters.append(SearchHelper.filterOutParticipantType())
        return GroupsSubscriptionData(
            spaceId: setDocument.spaceId,
            identifier: groupSubscriptionId,
            relationKey: setDocument.activeView.groupRelationKey,
            filters: filters,
            source: setDocument.details?.filteredSetOf,
            collectionId: setDocument.isCollection() ? setDocument.objectId : nil
        )
    }
}
