import SwiftUI

struct EmojiIconView: View {
    
    // MARK: - Private
    
    private struct Config {
        let side: CGFloat
        let cornerRadius: CGFloat?
        let fontSize: CGFloat
        
        static let zero = Config(side: 0, cornerRadius: nil, fontSize: 0)
    }
    
    private static let configs = [
        Config(side: 16, cornerRadius: nil, fontSize: 12),
        Config(side: 18, cornerRadius: nil, fontSize: 14),
        Config(side: 40, cornerRadius: 8, fontSize: 24),
        Config(side: 48, cornerRadius: 10, fontSize: 30),
        Config(side: 64, cornerRadius: 14, fontSize: 36),
        Config(side: 80, cornerRadius: 18, fontSize: 48)
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
            Text(text)
                .font(.system(size: config.fontSize))
                .fixedSize()
        }
        .clipped()
        .ifLet(config.cornerRadius) { view, cornerRadius in
            view.background(Color.Stroke.tertiary)
                .cornerRadius(cornerRadius, style: .continuous)
        }
        .frame(idealWidth: 30, idealHeight: 30) // Default frame
    }
    
    private func updateConfig(size: CGSize) {
        let side = min(size.width, size.height)
        config = EmojiIconView.configs.first(where: { $0.side <= side }) ?? EmojiIconView.configs.last ?? .zero
    }
}
