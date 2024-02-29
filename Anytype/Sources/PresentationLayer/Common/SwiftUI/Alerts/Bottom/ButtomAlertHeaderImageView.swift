import Foundation
import SwiftUI
    
enum BottomAlertHeaderBackgroundStyle {
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

struct ButtomAlertHeaderImageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let icon: ImageAsset
    let style: BottomAlertHeaderBackgroundStyle
    
    var body: some View {
        ZStack {
            gradient
            Image(asset: icon)
        }
        .frame(height: 104)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var gradient: some View {
        if colorScheme == .light {
            GeometryReader { reader in
                RadialGradient(
                    colors: style.gradient,
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
