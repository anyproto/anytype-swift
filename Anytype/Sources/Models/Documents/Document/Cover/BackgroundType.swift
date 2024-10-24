import SwiftUI

enum ObjectBackgroundType: Codable, Equatable {
    case gradient(CoverGradient)
    case color(CoverColor)
    
    var asView: some View {
        Group {
            switch self {
            case .gradient(let coverGradient):
                coverGradient.gradientColor.asLinearGradient()
            case .color(let coverColor):
                coverColor.color
            }
        }
    }
    
    static var allGradients: [ObjectBackgroundType] {
        CoverGradient.allCases.map { .gradient($0) }
    }
    
    static var allColors: [ObjectBackgroundType] {
        CoverColor.allCases.map { .color($0) }
    }
    
    static var `default`: ObjectBackgroundType {
        .gradient(.sky)
    }
}
