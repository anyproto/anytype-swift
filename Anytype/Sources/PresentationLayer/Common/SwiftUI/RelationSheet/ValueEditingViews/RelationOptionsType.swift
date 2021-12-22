import Foundation
import SwiftUI

enum RelationOptionsType {
    
    case objects
    case tags([Relation.Tag.Option])
    
}

extension RelationOptionsType {
    
    var placeholder: String {
        switch self {
        case .objects: return "Empty".localized
        case .tags: return "No related options here. You can add some".localized
        }
    }
    
}
