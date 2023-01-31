import Foundation
import BlocksModels
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
            return Loc.nonExistentObject
        }
        
        let title: String

        switch layoutValue {
        case .note:
            title = firstLineSnippet
        default:
            title = name
        }

        return title.isEmpty ? Loc.untitled : title
    }
    
    var subtitle: String {
        return (type == ObjectTypeId.BundledTypeId.note.rawValue || description.isNotEmpty)
            ? description : firstLineSnippet
    }
    
    var homeLayout: HomeCellData.TitleLayout {
        switch objectIconImage {
        case .todo, .icon(.bookmark):
            return .horizontal
        default:
            return .vertical
        }
    }
    
    var mentionTitle: String {
        String(title.prefix(30)).replacingOccurrences(of: "\n", with: " ")
    }
    
    private var firstLineSnippet: String {
        return snippet.components(separatedBy: CharacterSet.newlines).first ?? snippet
    }
}
