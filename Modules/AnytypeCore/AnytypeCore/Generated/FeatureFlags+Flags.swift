// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var fullInlineSetImpl: Bool {
        value(for: .fullInlineSetImpl)
    }

    static var dndOnCollectionsAndSets: Bool {
        value(for: .dndOnCollectionsAndSets)
    }

    static var hideCoCreator: Bool {
        value(for: .hideCoCreator)
    }

    static var allContent: Bool {
        value(for: .allContent)
    }

    static var homeSpaceLevelChat: Bool {
        value(for: .homeSpaceLevelChat)
    }

    static var pinnedSpaces: Bool {
        value(for: .pinnedSpaces)
    }

    static var newSpacesLoading: Bool {
        value(for: .newSpacesLoading)
    }

    static var allContentWidgets: Bool {
        value(for: .allContentWidgets)
    }

    static var newTypeIcons: Bool {
        value(for: .newTypeIcons)
    }

    static var openMediaFileInPreview: Bool {
        value(for: .openMediaFileInPreview)
    }

    static var openBookmarkAsLink: Bool {
        value(for: .openBookmarkAsLink)
    }

    static var newSettings: Bool {
        value(for: .newSettings)
    }

    static var newPlusMenu: Bool {
        value(for: .newPlusMenu)
    }

    static var enablePushMessages: Bool {
        value(for: .enablePushMessages)
    }

    static var newOnboarding: Bool {
        value(for: .newOnboarding)
    }

    static var disableColorfulSeedPhrase: Bool {
        value(for: .disableColorfulSeedPhrase)
    }

    static var openTypeAsSet: Bool {
        value(for: .openTypeAsSet)
    }

    static var anyAppBetaTip: Bool {
        value(for: .anyAppBetaTip)
    }

    static var disableRestoreLastScreen: Bool {
        value(for: .disableRestoreLastScreen)
    }

    static var chatCounters: Bool {
        value(for: .chatCounters)
    }

    static var httpsLinkForObjectCopy: Bool {
        value(for: .httpsLinkForObjectCopy)
    }

    static var newPropertiesCreation: Bool {
        value(for: .newPropertiesCreation)
    }

    static var fixChatEmptyState: Bool {
        value(for: .fixChatEmptyState)
    }

    static var pluralNames: Bool {
        value(for: .pluralNames)
    }

    static var rainbowViews: Bool {
        value(for: .rainbowViews)
    }

    static var showAlertOnAssert: Bool {
        value(for: .showAlertOnAssert)
    }

    static var analytics: Bool {
        value(for: .analytics)
    }

    static var analyticsAlerts: Bool {
        value(for: .analyticsAlerts)
    }

    static var nonfatalAlerts: Bool {
        value(for: .nonfatalAlerts)
    }

    static var resetTips: Bool {
        value(for: .resetTips)
    }

    static var showAllTips: Bool {
        value(for: .showAllTips)
    }

    static var sharingExtensionShowContentTypes: Bool {
        value(for: .sharingExtensionShowContentTypes)
    }

    static var homeTestSwipeGeature: Bool {
        value(for: .homeTestSwipeGeature)
    }

    static var membershipTestTiers: Bool {
        value(for: .membershipTestTiers)
    }

    static var failReceiptValidation: Bool {
        value(for: .failReceiptValidation)
    }

    static var showGlobalSearchScore: Bool {
        value(for: .showGlobalSearchScore)
    }

    static var versionHistoryPaginationTest: Bool {
        value(for: .versionHistoryPaginationTest)
    }

    // All toggles
    static let features: [FeatureDescription] = [
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .hideCoCreator,
        .allContent,
        .homeSpaceLevelChat,
        .pinnedSpaces,
        .newSpacesLoading,
        .allContentWidgets,
        .newTypeIcons,
        .openMediaFileInPreview,
        .openBookmarkAsLink,
        .newSettings,
        .newPlusMenu,
        .enablePushMessages,
        .newOnboarding,
        .disableColorfulSeedPhrase,
        .openTypeAsSet,
        .anyAppBetaTip,
        .disableRestoreLastScreen,
        .chatCounters,
        .httpsLinkForObjectCopy,
        .newPropertiesCreation,
        .fixChatEmptyState,
        .pluralNames,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .analyticsAlerts,
        .nonfatalAlerts,
        .resetTips,
        .showAllTips,
        .sharingExtensionShowContentTypes,
        .homeTestSwipeGeature,
        .membershipTestTiers,
        .failReceiptValidation,
        .showGlobalSearchScore,
        .versionHistoryPaginationTest
    ]
}
