import Foundation

#warning("Fix scope for relation")
public extension RelationDetails {
    
    enum Scope: Hashable {
        /// stored within the object
        case object
        /// stored within the object type
        case type
        /// aggregated from the dataview of sets of the same object type
        case setOfTheSameType
        /// aggregated from the dataview of sets of the same object type
        case objectsOfTheSameType
        /// aggregated from relations library
        case library
        
        case UNRECOGNIZED(Int)
    }
}

extension RelationDetails.Scope {
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .object
        case 1: self = .type
        case 2: self = .setOfTheSameType
        case 3: self = .objectsOfTheSameType
        case 4: self = .library
        default: self = .UNRECOGNIZED(rawValue)
        }
    }
    
    var rawValue: Int {
        switch self {
        case .object: return 0
        case .type: return 1
        case .setOfTheSameType: return 2
        case .objectsOfTheSameType: return 3
        case .library: return 4
        case .UNRECOGNIZED(let i): return i
        }
    }
    
}
