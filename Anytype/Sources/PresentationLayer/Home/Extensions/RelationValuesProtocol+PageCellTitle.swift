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
            title = snippet
        case .file, .image:
            title = "\(name).\(fileExt)"
        default:
            title = name
        }

        return title.isEmpty ? Loc.untitled : title.replacedNewlinesWithSpaces
    }
    
    var subtitle: String {
        switch layoutValue {
        case .note:
            return description
        default:
            return description.isNotEmpty ? description : snippet.replacedNewlinesWithSpaces
        }
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
}
