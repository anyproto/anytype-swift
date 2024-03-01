import Foundation
import Services
import AnytypeCore

extension BundledRelationsValueProvider {

    var pageCellTitle: String {
        switch layoutValue {
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

        return objectName.isEmpty ? Loc.Object.Title.placeholder : objectName
    }

    var subtitle: String {
        switch layoutValue {
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
