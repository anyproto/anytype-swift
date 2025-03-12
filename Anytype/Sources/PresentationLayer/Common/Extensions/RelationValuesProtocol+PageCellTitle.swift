import Foundation
import Services
import AnytypeCore

extension BundledRelationsValueProvider {

    var pageCellTitle: String {
        switch resolvedLayoutValue {
        case .note:
            return snippet
        default:
            return name
        }
    }

    var title: String {
        if isDeleted {
            // TODO: Move to editor
            return Loc.nonExistentObject
        }

        return objectName.withPlaceholder
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
        String(title.prefix(30)).replacingOccurrences(of: "\n", with: " ")
    }
}
