import Foundation
import Services
import AnytypeCore

extension BundledRelationsValueProvider {

    var setTitle: String {
        switch resolvedLayoutValue {
        case .note:
            return snippet
        default:
            if FeatureFlags.pluralNames {
                return pluralName.isNotEmpty ? pluralName : name
            } else {
                return name
            }
        }
    }

    var title: String {
        if isDeleted {
            // TODO: Move to editor
            return Loc.nonExistentObject
        }

        return objectName.withPlaceholder
    }
    
    var pluralTitle: String {
        if isDeleted {
            // TODO: Move to editor
            return Loc.nonExistentObject
        }

        return pluralName.isNotEmpty ? pluralName : title
    }

    var subtitle: String {
        switch resolvedLayoutValue {
        case .note:
            return description
        default:
            return description.isNotEmpty ? description : snippet.replacedNewlinesWithSpaces
        }
    }

    var mentionTitle: String {
        if FeatureFlags.pluralNames {
            String(pluralTitle.prefix(30)).replacingOccurrences(of: "\n", with: " ")
        } else {
            String(title.prefix(30)).replacingOccurrences(of: "\n", with: " ")
        }
    }
}
