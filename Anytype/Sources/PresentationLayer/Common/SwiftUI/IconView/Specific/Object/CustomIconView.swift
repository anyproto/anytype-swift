import Foundation
import SwiftUI
import Services

extension CustomIconDataColor {
    var color: Color {
        switch self {
        case .selected(let color):
            color.color
        case .placeholder:
            .Shape.transperentPrimary
        }
    }
}

struct CustomIconView: View {
    
    private struct Config {
        let side: CGFloat
        let padding: CGFloat

        static let zero = Config(side: 0, padding: 0)
    }

    private static let configs = [
        Config(side: 16, padding: 0),
        Config(side: 18, padding: 0),
        Config(side: 32, padding: 6),
        Config(side: 40, padding: 8),
        Config(side: 48, padding: 9),
        Config(side: 64, padding: 14),
        Config(side: 80, padding: 16),
        Config(side: 96, padding: 22),
        Config(side: 112, padding: 24)
    ].sorted(by: { $0.side > $1.side }) // Order by DESC side for simple search
    
    
    let icon: CustomIcon
    let color: Color
    
    init(icon: CustomIcon, iconColor: CustomIconDataColor) {
        self.icon = icon
        self.color = iconColor.color
    }
    
    var body: some View {
        GeometryReader { reader in
            Image(asset: icon.imageAsset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(padding(size: reader.size))
                .frame(width: reader.size.width, height: reader.size.height)
                .foregroundStyle(color)
        }
    }
    
    private func padding(size: CGSize) -> CGFloat {
        let side = min(size.width, size.height)
        let config = Self.configs.first(where: { $0.side <= side }) ?? Self.configs.last ?? .zero
        return config.padding
    }
}
