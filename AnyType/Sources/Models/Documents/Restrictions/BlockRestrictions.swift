
import BlocksModels

protocol BlockRestrictions {
    var canApplyBold: Bool { get }
    var canApplyOtherMarkup: Bool { get }
    var canApplyBlockColor: Bool { get }
    var canApplyBackgroundColor: Bool { get }
    var canApplyMention: Bool { get }
    var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes] { get }
    var availableAlignments: [BlockInformation.Alignment] { get }
}
