import Foundation
import SwiftUI
import AnytypeCore

struct EmojiIconView: View {
    
    private struct Config {
        let side: CGFloat
        let cornerRadius: CGFloat?
        
        static let zero = Config(side: 0, cornerRadius: nil)
    }
    
    private static let configs = [
        Config(side: 16, cornerRadius: nil),
        Config(side: 18, cornerRadius: nil),
        Config(side: 20, cornerRadius: nil),
        Config(side: 40, cornerRadius: 8),
        Config(side: 48, cornerRadius: 10),
        Config(side: 64, cornerRadius: 14),
        Config(side: 80, cornerRadius: 18)
    ].sorted(by: { $0.side > $1.side }) // Order by DESC side for simple search
    
    let emoji: Emoji
    
    var body: some View {
        GeometryReader { reader in
            ImageCharIconView(text: emoji.value)
                .ifLet(config(size: reader.size).cornerRadius) { view, radius in
                    view
                        .background(Color.Shape.secondary)
                        .cornerRadius(radius)
                }
        }
    }
    
    private func config(size: CGSize) -> Config {
        let side = min(size.width, size.height)
        return Self.configs.first(where: { $0.side <= side }) ?? Self.configs.last ?? .zero
    }
}
