import Foundation
import SwiftUI
import Services

struct CustomIconView: View {
    
    private struct Config {
        let side: CGFloat
        let padding: CGFloat

        static let zero = Config(side: 0, padding: 0)
    }

    private static let configs = [
        Config(side: 16, padding: 0),
        Config(side: 18, padding: 0),
        Config(side: 40, padding: 6),
        Config(side: 48, padding: 6),
        Config(side: 64, padding: 8)
    ].sorted(by: { $0.side > $1.side }) // Order by DESC side for simple search
    
    
    let icon: CustomIcon
    let color: Color
    
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

extension CustomIconView {
    init(icon: CustomIcon, iconColor: CustomIconColor) {
        self.icon = icon
        self.color = iconColor.color
    }
}
