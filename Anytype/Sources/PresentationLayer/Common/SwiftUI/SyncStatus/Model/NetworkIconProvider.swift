import Services
import SwiftUI

enum NetworkIconBackground: Equatable {
    case `static`(Color)
    case animation(start: Color, end: Color)
    
    var initialColor: Color {
        switch self {
        case .static(let color):
            color
        case .animation(let start, _):
            start
        }
    }
}

protocol NetworkIconProvider: Equatable {
    var icon: ImageAsset { get }
    var background: NetworkIconBackground { get }
}
