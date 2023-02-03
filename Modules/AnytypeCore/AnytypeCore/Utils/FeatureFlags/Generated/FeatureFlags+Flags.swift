// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var homeWidgets: Bool {
        value(for: .homeWidgets)
    }

    static var fullInlineSetImpl: Bool {
        value(for: .fullInlineSetImpl)
    }

    static var fixUpdateRelationBlock: Bool {
        value(for: .fixUpdateRelationBlock)
    }

    static var setTypeContextMenu: Bool {
        value(for: .setTypeContextMenu)
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
        .setKanbanView,
        .homeWidgets,
        .fullInlineSetImpl,
        .fixUpdateRelationBlock,
        .setTypeContextMenu,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .middlewareLogs
    ]
}
