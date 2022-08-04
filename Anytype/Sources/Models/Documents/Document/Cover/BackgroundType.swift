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
        .gradient(.sky)
    }
}
