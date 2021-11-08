import BlocksModels

extension MiddlewareColor {
    
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
        case .lime: return .darkGreen
        case .grey: return .darkColdGray
        case .`default`: return .grayscale90
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
        case .lime: return .lightGreen
        case .grey: return .lightColdGray
        case .`default`: return .grayscaleWhite
        }
    }
    
}
