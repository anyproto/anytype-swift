// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var spaceUxTypes: Bool {
        value(for: .spaceUxTypes)
    }

    static var spaceLoadingForScreen: Bool {
        value(for: .spaceLoadingForScreen)
    }

    static var binScreenEmptyAction: Bool {
        value(for: .binScreenEmptyAction)
    }

    static var muteSpacePossibility: Bool {
        value(for: .muteSpacePossibility)
    }

    static var addNotificationsSettings: Bool {
        value(for: .addNotificationsSettings)
    }

    static var swipeToReply: Bool {
        value(for: .swipeToReply)
    }

    static var newSharingExtension: Bool {
        value(for: .newSharingExtension)
    }

    static var newSpaceMembersFlow: Bool {
        value(for: .newSpaceMembersFlow)
    }

    static var removeMessagesFromNotificationsCenter: Bool {
        value(for: .removeMessagesFromNotificationsCenter)
    }

    static var mediaCarouselForWidgets: Bool {
        value(for: .mediaCarouselForWidgets)
    }

    static var updatedHomePlusMenu: Bool {
        value(for: .updatedHomePlusMenu)
    }

    static var fixCollectionViewReuseCrashInEditor: Bool {
        value(for: .fixCollectionViewReuseCrashInEditor)
    }

    static var loadAttachmentsOnHomePlusMenu: Bool {
        value(for: .loadAttachmentsOnHomePlusMenu)
    }

    static var vaultBackToRoots: Bool {
        value(for: .vaultBackToRoots)
    }

    static var brandNewAuthFlow: Bool {
        value(for: .brandNewAuthFlow)
    }

    static var homeObjectTypeWidgets: Bool {
        value(for: .homeObjectTypeWidgets)
    }

    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var fullInlineSetImpl: Bool {
        value(for: .fullInlineSetImpl)
    }

    static var dndOnCollectionsAndSets: Bool {
        value(for: .dndOnCollectionsAndSets)
    }

    static var hideWebPayments: Bool {
        value(for: .hideWebPayments)
    }

    static var enableStreamSpaceType: Bool {
        value(for: .enableStreamSpaceType)
    }

    static var aiToolInSet: Bool {
        value(for: .aiToolInSet)
    }

    static var anyAppBetaTip: Bool {
        value(for: .anyAppBetaTip)
    }

    static var guideUseCaseForDataSpace: Bool {
        value(for: .guideUseCaseForDataSpace)
    }

    static var chatLayoutInsideSpace: Bool {
        value(for: .chatLayoutInsideSpace)
    }

    static var joinStream: Bool {
        value(for: .joinStream)
    }

    static var simpleSetForTypes: Bool {
        value(for: .simpleSetForTypes)
    }

    static var doNotWaitCompletionInAnytypePreview: Bool {
        value(for: .doNotWaitCompletionInAnytypePreview)
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

    static var logMiddlewareRequests: Bool {
        value(for: .logMiddlewareRequests)
    }

    static var showPushMessagesInForeground: Bool {
        value(for: .showPushMessagesInForeground)
    }

    static var skipOnboardingEmailCollection: Bool {
        value(for: .skipOnboardingEmailCollection)
    }

    // All toggles
    static let features: [FeatureDescription] = [
        .spaceUxTypes,
        .spaceLoadingForScreen,
        .binScreenEmptyAction,
        .muteSpacePossibility,
        .addNotificationsSettings,
        .swipeToReply,
        .newSharingExtension,
        .newSpaceMembersFlow,
        .removeMessagesFromNotificationsCenter,
        .mediaCarouselForWidgets,
        .updatedHomePlusMenu,
        .fixCollectionViewReuseCrashInEditor,
        .loadAttachmentsOnHomePlusMenu,
        .vaultBackToRoots,
        .brandNewAuthFlow,
        .homeObjectTypeWidgets,
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .hideWebPayments,
        .enableStreamSpaceType,
        .aiToolInSet,
        .anyAppBetaTip,
        .guideUseCaseForDataSpace,
        .chatLayoutInsideSpace,
        .joinStream,
        .simpleSetForTypes,
        .doNotWaitCompletionInAnytypePreview,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .analyticsAlerts,
        .nonfatalAlerts,
        .resetTips,
        .showAllTips,
        .sharingExtensionShowContentTypes,
        .membershipTestTiers,
        .failReceiptValidation,
        .showGlobalSearchScore,
        .versionHistoryPaginationTest,
        .networkHTTPSRequestsLogger,
        .logMiddlewareRequests,
        .showPushMessagesInForeground,
        .skipOnboardingEmailCollection
    ]
}
