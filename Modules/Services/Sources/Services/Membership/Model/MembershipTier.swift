import ProtobufMessages


public enum MembershipTierId: Hashable, Identifiable, Equatable {
    case explorer
    case builder
    case coCreator
    
    case custom(id: Int32)
    
    public var id: Self {
        return self
    }
    
    init?(intId: Int32) {
        switch intId {
        case 0:
            return nil
        case 1:
            self = .explorer
        case 4:
            self = .builder
        case 5:
            self = .coCreator
        default:
            self = .custom(id: Int32(intId))
        }
    }
}

public struct MembershipTier: Equatable {
    public let id: MembershipTierId
    
    public init(id: MembershipTierId) {
        self.id = id
    }
}


// MARK: - Middleware model mapping

extension Anytype_Model_MembershipTierData {
    func asModel() -> MembershipTier? {
        guard let tierId = MembershipTierId(intId: Int32(id)) else { return nil }
        
        return MembershipTier(id: tierId)
    }
}

// TODO: Use API
extension MembershipTierId {
    var middlewareId: Int32 {
        switch self {
        case .explorer:
            1
        case .builder:
            4
        case .coCreator:
            5
        case .custom(let id):
            id
        }
    }
}
