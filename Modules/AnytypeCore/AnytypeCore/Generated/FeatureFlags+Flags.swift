// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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

    static var allObjectsFromLibrary: Bool {
        value(for: .allObjectsFromLibrary)
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

    static var objectTypeWidgets: Bool {
        value(for: .objectTypeWidgets)
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

    static var spaceUxTypes: Bool {
        value(for: .spaceUxTypes)
    }

    static var enableStreamSpaceType: Bool {
        value(for: .enableStreamSpaceType)
    }

    static var firebasePushMessages: Bool {
        value(for: .firebasePushMessages)
    }

    static var enablePushMessages: Bool {
        value(for: .enablePushMessages)
    }

    static var aiToolInSet: Bool {
        value(for: .aiToolInSet)
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

    static var binWidgetFromLibrary: Bool {
        value(for: .binWidgetFromLibrary)
    }

    static var anyAppBetaTip: Bool {
        value(for: .anyAppBetaTip)
    }

    static var guideUseCaseForDataSpace: Bool {
        value(for: .guideUseCaseForDataSpace)
    }

    static var disableRestoreLastScreen: Bool {
        value(for: .disableRestoreLastScreen)
    }

    static var spaceHubNewTitle: Bool {
        value(for: .spaceHubNewTitle)
    }

    static var chatLayoutInsideSpace: Bool {
        value(for: .chatLayoutInsideSpace)
    }

    static var chatCounters: Bool {
        value(for: .chatCounters)
    }

    static var joinStream: Bool {
        value(for: .joinStream)
    }

    static var httpsLinkForObjectCopy: Bool {
        value(for: .httpsLinkForObjectCopy)
    }

    static var newPropertiesCreation: Bool {
        value(for: .newPropertiesCreation)
    }

    static var pluralNames: Bool {
        value(for: .pluralNames)
    }

    static var countersOnSpaceHub: Bool {
        value(for: .countersOnSpaceHub)
    }

    static var simpleSetForTypes: Bool {
        value(for: .simpleSetForTypes)
    }

    static var doNotWaitCompletionInAnytypePreview: Bool {
        value(for: .doNotWaitCompletionInAnytypePreview)
    }

    static var plusButtonOnWidgets: Bool {
        value(for: .plusButtonOnWidgets)
    }

    static var spaceLoadingForScreen: Bool {
        value(for: .spaceLoadingForScreen)
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

    static var networkHTTPSRequestsLogger: Bool {
        value(for: .networkHTTPSRequestsLogger)
    }

    // All toggles
    static let features: [FeatureDescription] = [
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .hideCoCreator,
        .allObjectsFromLibrary,
        .homeSpaceLevelChat,
        .pinnedSpaces,
        .newSpacesLoading,
        .objectTypeWidgets,
        .newTypeIcons,
        .openMediaFileInPreview,
        .openBookmarkAsLink,
        .newSettings,
        .newPlusMenu,
        .spaceUxTypes,
        .enableStreamSpaceType,
        .firebasePushMessages,
        .enablePushMessages,
        .aiToolInSet,
        .newOnboarding,
        .disableColorfulSeedPhrase,
        .openTypeAsSet,
        .binWidgetFromLibrary,
        .anyAppBetaTip,
        .guideUseCaseForDataSpace,
        .disableRestoreLastScreen,
        .spaceHubNewTitle,
        .chatLayoutInsideSpace,
        .chatCounters,
        .joinStream,
        .httpsLinkForObjectCopy,
        .newPropertiesCreation,
        .pluralNames,
        .countersOnSpaceHub,
        .simpleSetForTypes,
        .doNotWaitCompletionInAnytypePreview,
        .plusButtonOnWidgets,
        .spaceLoadingForScreen,
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
        .versionHistoryPaginationTest,
        .networkHTTPSRequestsLogger
    ]
}
