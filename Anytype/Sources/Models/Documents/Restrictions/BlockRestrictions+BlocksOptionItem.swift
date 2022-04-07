import BlocksModels
import UIKit
import AnytypeCore

extension Array where Element == BlockRestrictions {
    var mergedOptions: Set<BlocksOptionItem> {
        var options = Set(BlocksOptionItem.allCases)

        forEach { element in
            if !element.canDeleteOrDuplicate {
                options.remove(.delete)
                options.remove(.duplicate)
            }

            if !element.canApplyStyle(.smartblock(.page)) {
                options.remove(.turnInto)
            }
        }

        if count > 1 {
            options.remove(.addBlockBelow)
        }

        return options
    }
}

extension Array where Element == BlockInformation {
    var blocksOptionItems: [BlocksOptionItem] {
        var isDownloadAvailable = true
        var isStyleAvailable = true

        var restrictions = [BlockRestrictions]()

        forEach { element in
            if case let .file(type) = element.content {
                if type.state != .done { isDownloadAvailable = false }
            } else {
                isDownloadAvailable = false
            }

            if !element.content.isText {
                isStyleAvailable = false
            }

            let restriction = BlockRestrictionsBuilder.build(contentType: element.content.type)
            restrictions.append(restriction)
        }

        var mergedItems = restrictions.mergedOptions

        if !isDownloadAvailable || count > 1 {
            mergedItems.remove(.download)
        }

        if !isStyleAvailable || count > 1 {
            mergedItems.remove(.style)
        }

        if !FeatureFlags.objectPreview {
            mergedItems.remove(.preview)
        }

        var isPreviewAvailable = false
        if case .link = first?.content, count == 1 {
            isPreviewAvailable = true
        }

        if !isPreviewAvailable {
            mergedItems.remove(.preview)
        }

        if FeatureFlags.clipboard {
            if !UIPasteboard.general.hasSlots {
                mergedItems.remove(.paste)
            }
        } else {
            mergedItems.remove(.copy)
            mergedItems.remove(.paste)
        }

        return Array<BlocksOptionItem>(mergedItems).sorted()
    }
}
