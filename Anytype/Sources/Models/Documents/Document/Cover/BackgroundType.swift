enum BackgroundType: Codable, Equatable {
    case gradient(CoverGradient)
    case color(CoverColor)
    
    static var allGradients: [BackgroundType] {
        CoverGradient.allCases.map { .gradient($0) }
    }
    
    static var allColors: [BackgroundType] {
        CoverColor.allCases.map { .color($0) }
    }
    
    static var `default`: BackgroundType {
        .gradient(.pinkOrange)
    }
}


#warning("Backward capability remove in version 20")
enum OldBackgroundType: Codable, Equatable {
    case gradient(CoverGradientData)
    case color(CoverColorData)
    
    var newType: BackgroundType? {
        switch self {
        case .gradient(let coverGradientData):
            guard let gradient = CoverGradient.allCases
                    .first(where: { $0.data.id == coverGradientData.id }) else { return nil }
            return .gradient(gradient)
        case .color(let coverColorData):
            guard let color = CoverColor.allCases
                    .first(where: { $0.data.id == coverColorData.id }) else { return nil }
            return .color(color)
        }
    }
}
