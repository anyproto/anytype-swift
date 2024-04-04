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

    static var galleryInstallation: Bool {
        value(for: .galleryInstallation)
    }

    static var newTypePicker: Bool {
        value(for: .newTypePicker)
    }

    static var newDateRelationCalendarView: Bool {
        value(for: .newDateRelationCalendarView)
    }

    static var newSelectRelationView: Bool {
        value(for: .newSelectRelationView)
    }

    static var newMultiSelectRelationView: Bool {
        value(for: .newMultiSelectRelationView)
    }

    static var newObjectSelectRelationView: Bool {
        value(for: .newObjectSelectRelationView)
    }

    static var newFileSelectRelationView: Bool {
        value(for: .newFileSelectRelationView)
    }

    static var newTextEditingRelationView: Bool {
        value(for: .newTextEditingRelationView)
    }

    static var multiplayer: Bool {
        value(for: .multiplayer)
    }

    static var membership: Bool {
        value(for: .membership)
    }

    static var newGlobalSearch: Bool {
        value(for: .newGlobalSearch)
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

    // All toggles
    static let features: [FeatureDescription] = [
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .galleryInstallation,
        .newTypePicker,
        .newDateRelationCalendarView,
        .newSelectRelationView,
        .newMultiSelectRelationView,
        .newObjectSelectRelationView,
        .newFileSelectRelationView,
        .newTextEditingRelationView,
        .multiplayer,
        .membership,
        .newGlobalSearch,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .analyticsAlerts,
        .nonfatalAlerts,
        .resetTips,
        .showAllTips,
        .sharingExtensionShowContentTypes,
        .homeTestSwipeGeature
    ]
}
