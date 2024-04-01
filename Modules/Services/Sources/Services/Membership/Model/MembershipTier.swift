import ProtobufMessages


public enum MembershipTierType: Hashable, Identifiable, Equatable {
    case explorer
    case builder
    case coCreator
    
    case custom(id: Int32)
    
    static let explorerId: Int32 = 1
    static let builderId: Int32 = 4
    static let coCreatorId: Int32 = 5
    
    public var id: Int32 {
        switch self {
        case .explorer:
            Self.explorerId
        case .builder:
            Self.builderId
        case .coCreator:
            Self.coCreatorId
        case .custom(let id):
            id
        }
    }
    
    init?(intId: Int32) {
        switch intId {
        case 0:
            return nil
        case Self.explorerId:
            self = .explorer
        case Self.builderId:
            self = .builder
        case Self.coCreatorId:
            self = .coCreator
        default:
            self = .custom(id: Int32(intId))
        }
    }
}

public enum MembershipAnyName: Hashable, Equatable {
    case none
    case some(minLenght: UInt32)
}

public struct MembershipTier: Hashable, Identifiable, Equatable {
    public let type: MembershipTierType
    public let name: String
    public let anyName: MembershipAnyName
    
    public var id: MembershipTierType { type }
    
    public init(
        type: MembershipTierType,
        name: String,
        anyName: MembershipAnyName
    ) {
        self.type = type
        self.name = name
        self.anyName = anyName
    }
}


// MARK: - Middleware model mapping

extension Anytype_Model_MembershipTierData {
    func asModel() -> MembershipTier? {
        guard let type = MembershipTierType(intId: Int32(id)) else { return nil }
        
        let anyName: MembershipAnyName = anyNamesCountIncluded > 0 ? .some(minLenght: anyNamesCountIncluded) : .none
        
        return MembershipTier(
            type: type,
            name: name,
            anyName: anyName
        )
    }
}
