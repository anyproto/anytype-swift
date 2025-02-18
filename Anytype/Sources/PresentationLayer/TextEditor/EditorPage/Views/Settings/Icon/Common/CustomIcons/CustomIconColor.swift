import SwiftUI

enum CustomIconColor: Int, CaseIterable {
    case gray
    case yellow
    case amber
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
    
    var iconOption: Int {
        rawValue + 1
    }
}
