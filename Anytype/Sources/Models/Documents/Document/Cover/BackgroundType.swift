enum BackgroundType: Codable, Equatable {
    case color(AnytypeColor)
    case gradient(AnytypeGradient)
    
    static var `default`: BackgroundType {
        .gradient(AnytypeGradient(name: "Default", startHex: "#74BDEC", endHex: "#CFD9D9"))
    }
}
