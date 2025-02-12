import Services
import SwiftUI

extension Relation {
    
    struct Object: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        var isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        
        let selectedObjects: [Option]
        let limitedObjectTypes: [String]
        
        var hasValue: Bool {
            selectedObjects.isNotEmpty
        }
        
        var isDeletedValue: Bool {
            selectedObjects.contains(where: \.isDeleted)
        }
        
        var links: Links? {
            Links(rawValue: key)
        }
    }
}

extension Relation.Object {

    struct Option: Hashable, Identifiable {
        let id: String
        
        let icon: Icon?
        let title: String
        let type: String
        let isArchived: Bool
        let isDeleted: Bool
        let editorScreenData: ScreenData?
    }
    
}

extension Relation.Object {
    
    enum Links: String {
        case links
        case backlinks
        
        func title(with count: Int) -> String {
            switch self {
            case .links:
                return Loc.linksCount(count)
            case .backlinks:
                return Loc.backlinksCount(count)
            }
        }
    }
    
}
