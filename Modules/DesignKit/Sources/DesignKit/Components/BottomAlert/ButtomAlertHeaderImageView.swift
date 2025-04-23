import Foundation
import SwiftUI
import Assets

public enum BottomAlertHeaderBackgroundColor {
    case green
    case blue
    case red
    
    fileprivate var gradient: [Color] {
        switch self {
        case .green:
            return [.BottomAlert.greenStart, .BottomAlert.greenEnd]
        case .blue:
            return [.BottomAlert.blueStart, .BottomAlert.blueEnd]
        case .red:
            return [.BottomAlert.redStart, .BottomAlert.redEnd]
        }
    }
}
    
public enum BottomAlertHeaderBackgroundStyle {
    case color(BottomAlertHeaderBackgroundColor)
    case plain
}

public struct ButtomAlertHeaderImageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let icon: ImageAsset
    let style: BottomAlertHeaderBackgroundStyle
    
    public init(icon: ImageAsset, style: BottomAlertHeaderBackgroundStyle) {
        self.icon = icon
        self.style = style
    }
    
    public var body: some View {
        ZStack {
            background
            Image(asset: icon)
        }
        .frame(height: 104)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var background: some View {
        if colorScheme == .light {
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
            case .plain:
                EmptyView()
            }
        }
    }
}
