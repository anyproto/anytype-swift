enum MiddlewareRelationColor: String {
    
    case yellow
    case orange
    case red
    case pink
    case purple
    case blue
    case ice
    case teal
    case green
    case grey
    
}

extension MiddlewareRelationColor {
    
    var asDarkColor: AnytypeColor {
        switch self {
        case .yellow: return .darkLemon
        case .orange: return .darkAmber
        case .red: return .darkRed
        case .pink: return .darkPink
        case .purple: return .darkPurple
        case .blue: return .darkUltramarine
        case .ice: return .darkBlue
        case .teal: return .darkTeal
        case .green: return .darkGreen
        case .grey: return .darkColdGray
        }
    }
    
    var asLightColor: AnytypeColor {
        switch self {
        case .yellow: return .lightLemon
        case .orange: return .lightAmber
        case .red: return .lightRed
        case .pink: return .lightPink
        case .purple: return .lightPurple
        case .blue: return .lightUltramarine
        case .ice: return .lightBlue
        case .teal: return .lightTeal
        case .green: return .lightGreen
        case .grey: return .lightColdGray
        }
    }
    
}
