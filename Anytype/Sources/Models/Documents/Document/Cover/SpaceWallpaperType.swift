import SwiftUI

enum SpaceWallpaperType: Codable, Equatable {
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
    
    static var allGradients: [SpaceWallpaperType] {
        CoverGradient.allCases.map { .gradient($0) }
    }
    
    static var allColors: [SpaceWallpaperType] {
        CoverColor.allCases.map { .color($0) }
    }
    
    static var `default`: SpaceWallpaperType {
        .gradient(.sky)
    }
}
