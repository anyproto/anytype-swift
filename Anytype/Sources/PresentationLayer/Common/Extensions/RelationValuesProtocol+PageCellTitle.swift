import Foundation
import Services
import AnytypeCore

extension BundledPropertiesValueProvider {

    var setTitle: String {
        switch resolvedLayoutValue {
        case .note:
            snippet
        default:
            pluralName.isNotEmpty ? pluralName : name
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
        String(pluralTitle.prefix(30)).replacingOccurrences(of: "\n", with: " ")
    }
}
