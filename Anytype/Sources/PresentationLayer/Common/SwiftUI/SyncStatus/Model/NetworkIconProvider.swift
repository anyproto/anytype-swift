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

struct NetworkIconData: Equatable {
    let icon: ImageAsset
    let color: Color
}

protocol NetworkIconProvider: Equatable {
    var iconData: NetworkIconData { get }
    var background: NetworkIconBackground { get }
}
