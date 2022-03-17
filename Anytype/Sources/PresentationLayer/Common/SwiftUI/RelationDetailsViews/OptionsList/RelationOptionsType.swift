import Foundation
import SwiftUI

enum RelationOptionsType {
    
    case objects
    case tags([Relation.Tag.Option])
    case files
    
}

extension RelationOptionsType {
    
    var placeholder: String {
        switch self {
        case .objects: return "Empty".localized
        case .tags, .files: return "No related options here. You can add some".localized
        }
    }
    
}
