// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var showAllButtonInWidgets: Bool {
        value(for: .showAllButtonInWidgets)
    }

    static var turnOffAutomaticWidgetOpening: Bool {
        value(for: .turnOffAutomaticWidgetOpening)
    }

    static var channelTypeSwitcher: Bool {
        value(for: .channelTypeSwitcher)
    }

    static var showUploadStatusIndicator: Bool {
        value(for: .showUploadStatusIndicator)
    }

    static var newObjectSettings: Bool {
        value(for: .newObjectSettings)
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

    static var demoOneToOneSpaces: Bool {
        value(for: .demoOneToOneSpaces)
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

    static var spaceHubAlwaysShowLoading: Bool {
        value(for: .spaceHubAlwaysShowLoading)
    }

    static var showHangedObjects: Bool {
        value(for: .showHangedObjects)
    }

    // All toggles
    static let features: [FeatureDescription] = [
        .showAllButtonInWidgets,
        .turnOffAutomaticWidgetOpening,
        .channelTypeSwitcher,
        .showUploadStatusIndicator,
        .newObjectSettings,
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .demoOneToOneSpaces,
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
        .skipOnboardingEmailCollection,
        .spaceHubAlwaysShowLoading,
        .showHangedObjects
    ]
}
