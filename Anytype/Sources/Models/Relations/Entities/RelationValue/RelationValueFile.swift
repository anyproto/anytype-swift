import Foundation
import BlocksModels
import SwiftUI

extension RelationValue {
    
    struct File: RelationValueProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool

        let files: [Option]
        
        var hasValue: Bool {
            files.isNotEmpty
        }
    }
    
}

extension RelationValue.File {
    
    struct Option: Hashable, Identifiable {
        
        let id: String
        
        let icon: ObjectIconImage
        let title: String
        
    }
    
}
