import Testing
import SwiftUI
@testable import Anytype
import Services

// FeatureFlags.muteAndHide defaults to true; see FeatureDescription+Flags.swift.
struct ParentObjectUnreadBadgeTests {

    @Test func hasMentions_trueWhenCountPositive() {
        #expect(makeBadge(unreadMentionCount: 0).hasMentions == false)
        #expect(makeBadge(unreadMentionCount: 1).hasMentions == true)
        #expect(makeBadge(unreadMentionCount: 99).hasMentions == true)
    }

    @Test func muted_trueWhenModeNotAll() {
        #expect(makeBadge(notificationMode: .all).muted == false)
        #expect(makeBadge(notificationMode: .mentions).muted == true)
        #expect(makeBadge(notificationMode: .nothing).muted == true)
    }

    @Test func shouldShowUnreadCounter_subscribedWithUnread_modeAll() {
        let badge = makeBadge(unreadMessageCount: 3, isSubscribed: true, notificationMode: .all)
        #expect(badge.shouldShowUnreadCounter == true)
    }

    @Test func shouldShowUnreadCounter_unsubscribed_alwaysFalse() {
        let badge = makeBadge(unreadMessageCount: 5, isSubscribed: false, notificationMode: .all)
        #expect(badge.shouldShowUnreadCounter == false)
    }

    @Test func shouldShowUnreadCounter_subscribedWithZeroCount_false() {
        let badge = makeBadge(unreadMessageCount: 0, isSubscribed: true, notificationMode: .all)
        #expect(badge.shouldShowUnreadCounter == false)
    }

    @Test func shouldShowUnreadCounter_subscribedNothingMode_false() {
        let badge = makeBadge(unreadMessageCount: 3, isSubscribed: true, notificationMode: .nothing)
        #expect(badge.shouldShowUnreadCounter == false)
    }

    @Test func hasVisibleCounters_trueWhenEitherMentionsOrCounter() {
        let mentionsOnly = makeBadge(unreadMentionCount: 1, isSubscribed: false, notificationMode: .all)
        let counterOnly = makeBadge(unreadMessageCount: 1, isSubscribed: true, notificationMode: .all)
        let both = makeBadge(unreadMessageCount: 1, unreadMentionCount: 1, isSubscribed: true, notificationMode: .all)
        let neither = makeBadge(notificationMode: .all)

        #expect(mentionsOnly.hasVisibleCounters == true)
        #expect(counterOnly.hasVisibleCounters == true)
        #expect(both.hasVisibleCounters == true)
        #expect(neither.hasVisibleCounters == false)
    }

    @Test func titleColor_secondaryWhenNothingMode_otherwisePrimary() {
        #expect(makeBadge(notificationMode: .all).titleColor == .Text.primary)
        #expect(makeBadge(notificationMode: .mentions).titleColor == .Text.primary)
        #expect(makeBadge(notificationMode: .nothing).titleColor == .Text.secondary)
    }

    // MARK: - Fixtures

    private func makeBadge(
        unreadMessageCount: Int = 0,
        unreadMentionCount: Int = 0,
        isSubscribed: Bool = true,
        notificationMode: SpacePushNotificationsMode = .all
    ) -> ParentObjectUnreadBadge {
        ParentObjectUnreadBadge(
            unreadMessageCount: unreadMessageCount,
            unreadMentionCount: unreadMentionCount,
            isSubscribed: isSubscribed,
            notificationMode: notificationMode
        )
    }
}
