// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var muteSpacePossibility: Bool {
        value(for: .muteSpacePossibility)
    }

    static var addNotificationsSettings: Bool {
        value(for: .addNotificationsSettings)
    }

    static var swipeToReply: Bool {
        value(for: .swipeToReply)
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

    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var fullInlineSetImpl: Bool {
        value(for: .fullInlineSetImpl)
    }

    static var dndOnCollectionsAndSets: Bool {
        value(for: .dndOnCollectionsAndSets)
    }

    static var anyAppBetaTip: Bool {
        value(for: .anyAppBetaTip)
    }

    static var multichats: Bool {
        value(for: .multichats)
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
        .muteSpacePossibility,
        .addNotificationsSettings,
        .swipeToReply,
        .newSpaceMembersFlow,
        .removeMessagesFromNotificationsCenter,
        .mediaCarouselForWidgets,
        .fixCollectionViewReuseCrashInEditor,
        .loadAttachmentsOnHomePlusMenu,
        .vaultBackToRoots,
        .brandNewAuthFlow,
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .anyAppBetaTip,
        .multichats,
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
        .networkHTTPSRequestsLogger,
        .logMiddlewareRequests,
        .showPushMessagesInForeground,
        .skipOnboardingEmailCollection
    ]
}
