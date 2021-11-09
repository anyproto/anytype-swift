enum BackgroundType: Codable, Equatable {
    case color(CoverColor)
    case gradient(CoverGradient)
    
    static var `default`: BackgroundType {
        .gradient(CoverGradient(name: "Default", startHex: "#74BDEC", endHex: "#CFD9D9"))
    }
}
