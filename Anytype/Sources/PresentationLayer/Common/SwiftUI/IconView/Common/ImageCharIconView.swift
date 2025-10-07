import Foundation
import SwiftUI

struct ImageCharIconView: View {
    
    private struct Config {
        let side: CGFloat
        let fontSize: CGFloat

        static let zero = Config(side: 0, fontSize: 0)
    }

    private static let configs = [
        Config(side: 16, fontSize: 11),
        Config(side: 18, fontSize: 12),
        Config(side: 20, fontSize: 13),
        Config(side: 32, fontSize: 20),
        Config(side: 40, fontSize: 24),
        Config(side: 48, fontSize: 28),
        Config(side: 56, fontSize: 28),
        Config(side: 64, fontSize: 40),
        Config(side: 80, fontSize: 44),
        Config(side: 96, fontSize: 64),
        Config(side: 112, fontSize: 64)
    ].sorted(by: { $0.side > $1.side }) // Order by DESC side for simple search
    
    let text: String
    let textColor: Color
    
    init(text: String, textColor: Color = .Control.secondary) {
        self.text = text
        self.textColor = textColor
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .center) {
                Text(text.prefix(1).uppercased())
                    .foregroundColor(textColor)
                    .font(font(size: reader.size))
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
        // Component doesn't support dynamic type size
        .dynamicTypeSize(.large)
    }
    
    private func font(size: CGSize) -> Font {
        let side = min(size.width, size.height)
        let config = Self.configs.first(where: { $0.side <= side }) ?? Self.configs.last ?? .zero
        return AnytypeFontBuilder.font(font: FontFamily.Inter.semiBold, size: config.fontSize)
    }
}
