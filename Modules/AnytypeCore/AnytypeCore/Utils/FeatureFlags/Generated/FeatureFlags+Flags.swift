// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var objectPreviewSettings: Bool {
        value(for: .objectPreviewSettings)
    }

    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var linktoObjectFromItself: Bool {
        value(for: .linktoObjectFromItself)
    }

    static var linkToObjectFromMarkup: Bool {
        value(for: .linkToObjectFromMarkup)
    }

    static var showBookmarkInSets: Bool {
        value(for: .showBookmarkInSets)
    }

    static var inlineMarkdown: Bool {
        value(for: .inlineMarkdown)
    }

    static var fixColorsForStyleMenu: Bool {
        value(for: .fixColorsForStyleMenu)
    }

    static var redesignBookmarkBlock: Bool {
        value(for: .redesignBookmarkBlock)
    }

    static var showSetsInChangeTypeSearchMenu: Bool {
        value(for: .showSetsInChangeTypeSearchMenu)
    }

    static var fixInsetMediaContent: Bool {
        value(for: .fixInsetMediaContent)
    }

    static var homeWidgets: Bool {
        value(for: .homeWidgets)
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

    static var middlewareLogs: Bool {
        value(for: .middlewareLogs)
    }

    // All toggles
    static let features: [FeatureDescription] = [
        .objectPreviewSettings,
        .setKanbanView,
        .linktoObjectFromItself,
        .linkToObjectFromMarkup,
        .showBookmarkInSets,
        .inlineMarkdown,
        .fixColorsForStyleMenu,
        .redesignBookmarkBlock,
        .showSetsInChangeTypeSearchMenu,
        .fixInsetMediaContent,
        .homeWidgets,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .middlewareLogs
    ]
}
