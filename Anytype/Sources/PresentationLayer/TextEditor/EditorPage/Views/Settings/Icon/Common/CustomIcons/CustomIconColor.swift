import SwiftUI

enum CustomIconColor: String, CaseIterable {
    case gray
    case amber
    case yellow
    case red
    case pink
    case purple
    case blue
    case sky
    case teal
    case green
    
    var color: Color {
        switch self {
        case .gray:
                .Control.active
        case .amber:
                .System.amber100
        case .yellow:
                .System.yellow
        case .red:
                .System.red
        case .pink:
                .System.pink
        case .purple:
                .System.purple
        case .blue:
                .System.blue
        case .sky:
                .System.sky
        case .teal:
                .System.teal
        case .green:
                .System.green
        }
    }
}
