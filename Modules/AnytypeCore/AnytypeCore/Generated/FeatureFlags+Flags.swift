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

    static var primitives: Bool {
        value(for: .primitives)
    }

    static var memberProfile: Bool {
        value(for: .memberProfile)
    }

    static var allContentWidgets: Bool {
        value(for: .allContentWidgets)
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
        .primitives,
        .memberProfile,
        .allContentWidgets,
        .openMediaFileInPreview,
        .openBookmarkAsLink,
        .newSettings,
        .newPlusMenu,
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
