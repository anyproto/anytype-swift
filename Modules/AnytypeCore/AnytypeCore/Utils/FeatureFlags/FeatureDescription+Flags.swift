import Foundation

public extension FeatureDescription {
    
    static let setTemplateSelection = FeatureDescription(
        title: "Additional button in sets to pick needed template",
        type: .feature(author: "db@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let setKanbanView = FeatureDescription(
        title: "Set kanban view",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let fullInlineSetImpl = FeatureDescription(
        title: "Full inline set impl (IOS-790)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false,
        debugValue: false
    )
    
    static let dndOnCollectionsAndSets = FeatureDescription(
        title: "Dnd on collections and sets (wating for the middle)",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.?.0"),
        defaultValue: false
    )
    
    static let migrationGuide = FeatureDescription(
        title: "Migration guide",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.22.0"),
        defaultValue: true
    )
    
    static let newAuthorization = FeatureDescription(
        title: "New authorization",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    static let compactListWidget = FeatureDescription(
        title: "Compact List widget",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    static let getMoreSpace = FeatureDescription(
        title: "Get more space - IOS-1307",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    static let fixAVCaptureSessionError = FeatureDescription(
        title: "Fix AVCaptureSession error",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    static let clearAccountDataOnDeletedStatus = FeatureDescription(
        title: "Clear cccount data on deleted status",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )
    
    static let fixAudioSession = FeatureDescription(
        title: "Fix AudioSession to avoid stop playing misic on the new onboarding",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )

    static let deleteObjectPlaceholder = FeatureDescription(
        title: "Delete object placeholder - IOS-960",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.23.0"),
        defaultValue: true
    )

    static let showAllFilesInBin = FeatureDescription(
        title: "Show all files in bin - IOS-1408",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.24.0"),
        defaultValue: true
    )

    static let superNewButtonLoadingState = FeatureDescription(
        title: "New Button loading state - IOS-1185",
        type: .feature(author: "m@anytype.io", releaseVersion: "0.24.0"),
        defaultValue: true
    )
    
    static let validateRecoveryPhrase = FeatureDescription(
        title: "Trim typed/inserted text in recovery phrase field",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.24.0"),
        defaultValue: true
    )
    
    static let colorfulRecoveryPhrase = FeatureDescription(
        title: "Colourful recovery phrase",
        type: .feature(author: "joe_pusya@anytype.io", releaseVersion: "0.24.0"),
        defaultValue: true
    )
    
    // MARK: - Debug
    
    static let rainbowViews = FeatureDescription(
        title: "Paint editor views 🌈",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let showAlertOnAssert = FeatureDescription(
        title: "Show alerts on asserts\n(only for test builds)",
        type: .debug,
        defaultValue: true
    )
    
    static let analytics = FeatureDescription(
        title: "Analytics - send events to Amplitude (only for test builds)",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
    
    static let analyticsAlerts = FeatureDescription(
        title: "Analytics - show alerts",
        type: .debug,
        defaultValue: false,
        debugValue: false
    )
}
