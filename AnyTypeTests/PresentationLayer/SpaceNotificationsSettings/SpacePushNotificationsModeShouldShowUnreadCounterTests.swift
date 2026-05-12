import Testing
@testable import Anytype
import AnytypeCore
import Services

// FeatureFlags.muteAndHide defaults to true (see FeatureDescription+Flags.swift),
// so these tests cover the production behavior.
struct SpacePushNotificationsModeShouldShowUnreadCounterTests {

    @Test func zeroCount_returnsFalse_inAllModes() {
        for mode in SpacePushNotificationsMode.displayModes {
            #expect(mode.shouldShowUnreadCounter(unreadCount: 0) == false)
            #expect(mode.shouldShowUnreadCounter(unreadCount: 0, isSubscribed: false) == false)
        }
    }

    @Test func unsubscribed_returnsFalse_evenWithUnread() {
        for mode in SpacePushNotificationsMode.displayModes {
            #expect(mode.shouldShowUnreadCounter(unreadCount: 5, isSubscribed: false) == false)
        }
    }

    @Test func subscribed_modeAll_returnsTrue() {
        #expect(SpacePushNotificationsMode.all.shouldShowUnreadCounter(unreadCount: 1) == true)
    }

    @Test func subscribed_modeMentions_returnsTrue() {
        #expect(SpacePushNotificationsMode.mentions.shouldShowUnreadCounter(unreadCount: 1) == true)
    }

    @Test func subscribed_modeNothing_returnsFalse_whenMuteAndHideOn() {
        // Default flag value (true) hides counters in .nothing mode for subscribed parents/chats.
        #expect(SpacePushNotificationsMode.nothing.shouldShowUnreadCounter(unreadCount: 1) == false)
    }

    @Test func defaultIsSubscribed_isTrue() {
        // Calling without isSubscribed should behave as the chat-row case (always subscribed).
        #expect(SpacePushNotificationsMode.all.shouldShowUnreadCounter(unreadCount: 1)
            == SpacePushNotificationsMode.all.shouldShowUnreadCounter(unreadCount: 1, isSubscribed: true))
    }
}
