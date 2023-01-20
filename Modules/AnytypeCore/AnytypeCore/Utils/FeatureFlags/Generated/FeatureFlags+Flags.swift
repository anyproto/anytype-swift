// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var objectPreviewSettings: Bool {
        value(for: .objectPreviewSettings)
    }

    static var cursorPosition: Bool {
        value(for: .cursorPosition)
    }

    static var hideBottomViewForStyleMenu: Bool {
        value(for: .hideBottomViewForStyleMenu)
    }

    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var redesignNewButton: Bool {
        value(for: .redesignNewButton)
    }

    static var linktoObjectFromItself: Bool {
        value(for: .linktoObjectFromItself)
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
        .cursorPosition,
        .hideBottomViewForStyleMenu,
        .setKanbanView,
        .redesignNewButton,
        .linktoObjectFromItself,
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
