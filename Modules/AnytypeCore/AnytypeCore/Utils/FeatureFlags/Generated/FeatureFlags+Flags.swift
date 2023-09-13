// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var setTemplateSelection: Bool {
        value(for: .setTemplateSelection)
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

    static var migrationGuide: Bool {
        value(for: .migrationGuide)
    }

    static var newAuthorization: Bool {
        value(for: .newAuthorization)
    }

    static var compactListWidget: Bool {
        value(for: .compactListWidget)
    }

    static var getMoreSpace: Bool {
        value(for: .getMoreSpace)
    }

    static var fixAVCaptureSessionError: Bool {
        value(for: .fixAVCaptureSessionError)
    }

    static var clearAccountDataOnDeletedStatus: Bool {
        value(for: .clearAccountDataOnDeletedStatus)
    }

    static var fixAudioSession: Bool {
        value(for: .fixAudioSession)
    }

    static var deleteObjectPlaceholder: Bool {
        value(for: .deleteObjectPlaceholder)
    }

    static var showAllFilesInBin: Bool {
        value(for: .showAllFilesInBin)
    }

    static var superNewButtonLoadingState: Bool {
        value(for: .superNewButtonLoadingState)
    }

    static var validateRecoveryPhrase: Bool {
        value(for: .validateRecoveryPhrase)
    }

    static var openBinObject: Bool {
        value(for: .openBinObject)
    }

    static var colorfulRecoveryPhrase: Bool {
        value(for: .colorfulRecoveryPhrase)
    }

    static var recentEditWidget: Bool {
        value(for: .recentEditWidget)
    }

    static var widgetTaskDone: Bool {
        value(for: .widgetTaskDone)
    }

    static var newCodeLanguages: Bool {
        value(for: .newCodeLanguages)
    }

    static var newSetSettings: Bool {
        value(for: .newSetSettings)
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

    // All toggles
    static let features: [FeatureDescription] = [
        .setTemplateSelection,
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .migrationGuide,
        .newAuthorization,
        .compactListWidget,
        .getMoreSpace,
        .fixAVCaptureSessionError,
        .clearAccountDataOnDeletedStatus,
        .fixAudioSession,
        .deleteObjectPlaceholder,
        .showAllFilesInBin,
        .superNewButtonLoadingState,
        .validateRecoveryPhrase,
        .openBinObject,
        .colorfulRecoveryPhrase,
        .recentEditWidget,
        .widgetTaskDone,
        .newCodeLanguages,
        .newSetSettings,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .analyticsAlerts,
        .nonfatalAlerts
    ]
}
