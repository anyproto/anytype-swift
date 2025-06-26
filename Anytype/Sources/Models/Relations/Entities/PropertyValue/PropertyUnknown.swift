import Foundation
import Services
import CoreImage

extension Relation {
    
    struct Unknown: PropertyProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        
        let value: String
        
        var hasValue: Bool {
            value.isNotEmpty
        }
        
        static func empty(id: String, key: String, name: String) -> Unknown {
            Unknown(id: id, key: key, name: name, isFeatured: false, isEditable: false, canBeRemovedFromObject: false, isDeleted: false, value: "")
        }
    }
    
}
