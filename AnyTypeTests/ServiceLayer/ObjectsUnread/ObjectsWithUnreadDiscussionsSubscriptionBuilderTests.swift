import Testing
import Foundation
@testable import Anytype
import Services
import ProtobufMessages

struct ObjectsWithUnreadDiscussionsSubscriptionBuilderTests {

    private let builder = ObjectsWithUnreadDiscussionsSubscriptionBuilder()

    // MARK: - Identity

    @Test func subscriptionId_isStable() {
        #expect(builder.subscriptionId == "SubscriptionId.ObjectsWithUnreadDiscussions")
    }

    @Test func build_identifierMatchesSubscriptionId() {
        let crossSearch = unwrap(builder.build())
        #expect(crossSearch?.identifier == builder.subscriptionId)
        #expect(crossSearch?.noDepSubscription == true)
    }

    // MARK: - Filter shape

    @Test func build_topLevelFilterIsOrOfTwoBranches() {
        let crossSearch = unwrap(builder.build())
        let filters = crossSearch?.filters ?? []

        #expect(filters.count == 1)
        #expect(filters[0].operator == .or)
        #expect(filters[0].nestedFilters.count == 2)
    }

    @Test func build_parentBranch_filtersByLayoutsArchiveStateAndCounters() {
        let crossSearch = unwrap(builder.build())
        let parentBranch = crossSearch?.filters[0].nestedFilters[0]

        #expect(parentBranch?.operator == .and)
        #expect(parentBranch?.nestedFilters.count == 5)

        let layoutFilter = parentBranch?.nestedFilters[0]
        #expect(layoutFilter?.relationKey == BundledPropertyKey.resolvedLayout.rawValue)
        #expect(layoutFilter?.condition == .in)

        let isArchivedFilter = parentBranch?.nestedFilters[1]
        #expect(isArchivedFilter?.relationKey == BundledPropertyKey.isArchived.rawValue)
        #expect(isArchivedFilter?.condition == .notEqual)

        let isDeletedFilter = parentBranch?.nestedFilters[2]
        #expect(isDeletedFilter?.relationKey == BundledPropertyKey.isDeleted.rawValue)
        #expect(isDeletedFilter?.condition == .notEqual)

        let isHiddenFilter = parentBranch?.nestedFilters[3]
        #expect(isHiddenFilter?.relationKey == BundledPropertyKey.isHidden.rawValue)
        #expect(isHiddenFilter?.condition == .notEqual)

        // Mentions are always also messages, so a single message-count > 0 filter covers both.
        let messageCountFilter = parentBranch?.nestedFilters[4]
        #expect(messageCountFilter?.relationKey == BundledPropertyKey.unreadMessageCount.rawValue)
        #expect(messageCountFilter?.condition == .greater)
    }

    @Test func build_discussionBranch_isPlainLayoutFilter() {
        let crossSearch = unwrap(builder.build())
        let discussionBranch = crossSearch?.filters[0].nestedFilters[1]

        #expect(discussionBranch?.relationKey == BundledPropertyKey.resolvedLayout.rawValue)
        #expect(discussionBranch?.condition == .in)
    }

    // MARK: - Keys

    @Test func build_includesAllConsumerKeys() {
        let crossSearch = unwrap(builder.build())
        let keys = Set(crossSearch?.keys ?? [])
        // Aggregator consumes:
        //   id / spaceId / resolvedLayout / discussionId / notificationSubscribers
        //   unreadMessageCount / unreadMentionCount / lastMessageDate
        // Row VMs consume the icon-image keys via ObjectDetails.objectIconImage / pluralTitle:
        //   name / pluralName / snippet / iconImage / iconEmoji / iconName / iconOption
        let required: Set<String> = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.resolvedLayout.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.pluralName.rawValue,
            BundledPropertyKey.snippet.rawValue,
            BundledPropertyKey.iconImage.rawValue,
            BundledPropertyKey.iconEmoji.rawValue,
            BundledPropertyKey.iconName.rawValue,
            BundledPropertyKey.iconOption.rawValue,
            BundledPropertyKey.discussionId.rawValue,
            BundledPropertyKey.lastMessageDate.rawValue,
            BundledPropertyKey.notificationSubscribers.rawValue,
            BundledPropertyKey.unreadMessageCount.rawValue,
            BundledPropertyKey.unreadMentionCount.rawValue
        ]
        #expect(required.isSubset(of: keys))
    }

    // MARK: - Helper

    private func unwrap(_ data: SubscriptionData) -> SubscriptionData.CrossSpaceSearch? {
        if case .crossSpaceSearch(let cs) = data { return cs }
        return nil
    }
}
