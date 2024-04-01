import ProtobufMessages


public enum MembershipTierType: Hashable, Identifiable, Equatable {
    case explorer
    case builder
    case coCreator
    
    case custom(id: UInt32)
    
    static let explorerId: UInt32 = 1
    static let builderId: UInt32 = 4
    static let coCreatorId: UInt32 = 5
    
    public var id: UInt32 {
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
    
    init?(intId: UInt32) {
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
            self = .custom(id: intId)
        }
    }
}

public enum MembershipAnyName: Hashable, Equatable {
    case none
    case some(minLenght: UInt32)
}

public enum MembershipFeature: Hashable, Equatable {
    public enum Value: Hashable, Equatable, CustomStringConvertible {
        case int(UInt32)
        case string(String)
        
        public var description: String {
            switch self {
            case .int(let int):
                String(describing: int)
            case .string(let string):
                string
            }
        }
    }
    
    case storageGbs(Value)
    case invites(Value)
    case spaceWriters(Value)
    case spaceReaders(Value)
    case sharedSpaces(Value)
}

public struct MembershipTier: Hashable, Identifiable, Equatable {
    public let type: MembershipTierType
    public let name: String
    public let anyName: MembershipAnyName
    public let features: [MembershipFeature]
    
    public var id: MembershipTierType { type }
    
    public init(
        type: MembershipTierType,
        name: String,
        anyName: MembershipAnyName,
        features: [MembershipFeature]
    ) {
        self.type = type
        self.name = name
        self.anyName = anyName
        self.features = features
    }
}


// MARK: - Middleware model mapping

extension Anytype_Model_MembershipTierData {
    func asModel() -> MembershipTier? {
        guard let type = MembershipTierType(intId: id) else { return nil }
        
        let anyName: MembershipAnyName = anyNamesCountIncluded > 0 ? .some(minLenght: anyNameMinLength) : .none
        
        return MembershipTier(
            type: type,
            name: name,
            anyName: anyName,
            features: getFeatures()
        )
    }
    
    func getFeatures() -> [MembershipFeature] {
        features.compactMap { feature in
            switch feature.featureID {
            case .storageGbs:
                return .storageGbs(extractFeatureValue(feature: feature))
            case .invites:
                return .invites(extractFeatureValue(feature: feature))
            case .spaceWriters:
                return .spaceWriters(extractFeatureValue(feature: feature))
            case .spaceReaders:
                return .spaceReaders(extractFeatureValue(feature: feature))
            case .sharedSpaces:
                return .sharedSpaces(extractFeatureValue(feature: feature))
            case .UNRECOGNIZED, .unknown:
                return nil
            }
        }
    }
    
    private func extractFeatureValue(feature: Feature) -> MembershipFeature.Value {
        if feature.valueUint > 0 {
            return .int(feature.valueUint)
        }
        
        return .string(feature.valueStr)
    }
}
