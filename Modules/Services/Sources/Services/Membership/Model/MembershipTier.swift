import ProtobufMessages


public enum MembershipTierType: Hashable, Identifiable, Equatable, Sendable {
    case legacyExplorer
    case starter
    case explorer
    case builder
    case coCreator
    case anyTeam
    
    case seatBasedTier
    
    case custom(id: UInt32)
    
    static let starterId: UInt32 = 21
    static let explorerId: UInt32 = 20
    static let builderId: UInt32 = 4
    static let coCreatorId: UInt32 = 5
    static let anyTeamId: UInt32 = 7
    static let seatBasedId: UInt32 = 1000
    static let legacyExplorerId: UInt32 = 1
    
    public var id: UInt32 {
        switch self {
        case .starter:
            Self.starterId
        case .explorer:
            Self.explorerId
        case .builder:
            Self.builderId
        case .coCreator:
            Self.coCreatorId
        case .anyTeam:
            Self.anyTeamId
        case .custom(let id):
            id
        case .legacyExplorer:
            Self.legacyExplorerId
        case .seatBasedTier:
            Self.seatBasedId
        }
    }
    
    init?(intId: UInt32) {
        switch intId {
        case 0:
            return nil
        case Self.starterId:
            self = .starter
        case Self.explorerId:
            self = .explorer
        case Self.builderId:
            self = .builder
        case Self.coCreatorId:
            self = .coCreator
        case Self.anyTeamId:
            self = .anyTeam
        case Self.legacyExplorerId:
            self = .legacyExplorer
        case Self.seatBasedId:
            self = .seatBasedTier
        default:
            self = .custom(id: intId)
        }
    }
}

public enum MembershipAnyName: Hashable, Equatable, Sendable {
    case none
    case some(minLenght: UInt32)
}

public enum MembershipColor: Equatable, Sendable {
    case green
    case blue
    case red
    case purple
    case ice
    
    init(string: String) {
        switch string {
        case "green":
            self = .green
        case "red":
            self = .red
        case "blue":
            self = .blue
        case "ice":
            self = .ice
        default:
            self = .purple
        }
    }
}

public struct MembershipTier: Hashable, Identifiable, Equatable, Sendable {
    public let type: MembershipTierType
    public let name: String
    public let description: String
    public let anyName: MembershipAnyName
    public let features: [String]
    public let paymentType: MembershipTierPaymentType?
    public let color: MembershipColor
    public let isTest: Bool
    public let iosProductID: String

    public var id: MembershipTierType { type }
    
    public init(
        type: MembershipTierType,
        name: String,
        description: String,
        anyName: MembershipAnyName,
        features: [String],
        paymentType: MembershipTierPaymentType?,
        color: MembershipColor,
        isTest: Bool,
        iosProductID: String
    ) {
        self.type = type
        self.name = name
        self.description = description
        self.anyName = anyName
        self.features = features
        self.paymentType = paymentType
        self.color = color
        self.isTest = isTest
        self.iosProductID = iosProductID
    }
}
