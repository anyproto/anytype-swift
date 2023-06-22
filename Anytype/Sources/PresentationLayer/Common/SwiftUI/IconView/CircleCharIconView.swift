import Foundation
import SwiftUI

struct CircleCharIconView: View {
    
    // MARK: - Private
    
    private struct Config {
        let side: CGFloat
        let fontSize: CGFloat
        
        static let zero = Config(side: 0, fontSize: 0)
    }
    
    private static let configs = [
        Config(side: 16, fontSize: 12),
        Config(side: 18, fontSize: 14),
        Config(side: 40, fontSize: 24),
        Config(side: 48, fontSize: 30),
        Config(side: 64, fontSize: 36),
        Config(side: 80, fontSize: 48)
    ].sorted(by: { $0.side > $1.side }) // Order by DESK side for simple search
    
    @State private var config: Config = .zero
    
    // MARK: - Public properties
    
    let text: String
    
    var body: some View {
        Color.clear.readSize { size in
            updateConfig(size: size)
        }
        .background {
            // Text shouldn't affect layout if font larger frame
            Text(text.prefix(1).capitalized)
                .font(AnytypeFontBuilder.font(name: .inter, size: config.fontSize, weight: .semibold))
                .foregroundColor(.Text.white)
                .fixedSize()
        }
        .clipped()
        .background {
            Circle()
                .foregroundColor(.Stroke.secondary)
        }
        .frame(idealWidth: 30, idealHeight: 30) // Default frame
    }
    
    private func updateConfig(size: CGSize) {
        let side = min(size.width, size.height)
        config = CircleCharIconView.configs.first(where: { $0.side <= side }) ?? CircleCharIconView.configs.last ?? .zero
    }
}
