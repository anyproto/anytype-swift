import SwiftUI

enum SpaceWallpaperType: Codable, Equatable {
    case blurredIcon
    case gradient(CoverGradient)
    case color(CoverColor)
    
    static var allGradients: [SpaceWallpaperType] {
        CoverGradient.allCases.map { .gradient($0) }
    }
    
    static var allColors: [SpaceWallpaperType] {
        CoverColor.allCases.map { .color($0) }
    }
    
    static var `default`: SpaceWallpaperType {
        .blurredIcon
    }
}
