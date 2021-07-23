
import Foundation

extension CollectionDifference.Change {
    
    var offset: Int {
        switch self {
        case let .insert(offset, _, _):
            return offset
        case let .remove(offset, _, _):
            return offset
        }
    }
    
    var element: ChangeElement {
        switch self {
        case let .insert(_, element, _):
            return element
        case let .remove(_, element, _):
            return element
        }
    }
}
