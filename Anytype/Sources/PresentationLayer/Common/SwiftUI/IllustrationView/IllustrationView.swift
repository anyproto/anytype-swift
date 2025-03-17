import Foundation
import SwiftUI

enum IllustrationViewColor {
    case blue
    case red
    
    fileprivate var gradient: [Color] {
        switch self {
        case .blue:
            return [.Dark.blue.opacity(0.3), .clear]
        case .red:
            return [.Dark.red.opacity(0.3), .clear]
        }
    }
    
    fileprivate var imageColor: Color {
        switch self {
        case .blue:
            return .Dark.blue
        case .red:
            return .Dark.red
        }
    }
}
    
enum IllustrationViewStyle {
    case color(IllustrationViewColor)
    
    fileprivate var imageColor: Color {
        switch self {
        case .color(let color):
            return color.imageColor
        }
    }
}

struct IllustrationView: View {
    
    let icon: ImageAsset?
    let style: IllustrationViewStyle
    
    var body: some View {
        ZStack {
            background
            if let icon {
                Image(asset: icon)
                    .foregroundColor(style.imageColor)
            }
        }
        .frame(height: 104)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var background: some View {
        switch style {
        case .color(let color):
            GeometryReader { reader in
                RadialGradient(
                    colors: color.gradient,
                    center: .center,
                    startRadius: 0,
                    endRadius: 50
                )
                .frame(width: reader.size.height, height: reader.size.height)
                .scaleEffect(CGSize(width: reader.size.width / 104, height: 1.0))
                .position(x: reader.frame(in: .local).midX, y: reader.frame(in: .local).midY)
            }
        }
    }
}
