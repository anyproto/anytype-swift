import SwiftUI
import Services

extension CustomIconColor {
    var color: Color {
        switch self {
        case .gray: .Control.secondary
        case .orange: .Pure.orange
        case .yellow: .Pure.yellow
        case .red: .Pure.red
        case .pink: .Pure.pink
        case .purple: .Pure.purple
        case .blue: .Pure.blue
        case .sky: .Pure.sky
        case .teal: .Pure.teal
        case .green: .Pure.green
        }
    }
}
