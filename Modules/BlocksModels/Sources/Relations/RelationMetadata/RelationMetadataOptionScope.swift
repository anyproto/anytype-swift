import Foundation

public extension RelationMetadata.Option {
    
    enum Scope: Hashable {
        case local
        case relation
        case format
        case unrecognized(Int)
    }
    
}

extension RelationMetadata.Option.Scope {
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .local
        case 1: self = .relation
        case 2: self = .format
        default: self = .unrecognized(rawValue)
        }
    }
    
    var rawValue: Int {
        switch self {
        case .local: return 0
        case .relation: return 1
        case .format: return 2
        case .unrecognized(let i): return i
        }
    }
}
