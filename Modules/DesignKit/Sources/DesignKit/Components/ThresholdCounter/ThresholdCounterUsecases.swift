public enum ThresholdCounterUsecase: String {
    case spaceName
    case spaceDescription
    
    public var threshold: Int {
        switch self {
        case .spaceName:
            50
        case .spaceDescription:
            200
        }
    }
    
    public var visibilityCount: Int {
        switch self {
        case .spaceName:
            10
        case .spaceDescription:
            50
        }
    }
}
