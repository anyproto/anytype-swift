import Foundation
import UIKit
import AnytypeCore

final class CharIconPainter: IconPainter {
    
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

    let text: String
    
    init(text: String) {
        self.text = String(text.prefix(1))
    }
    
    // IconPainter
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {}
    
    func prepare(bounds: CGRect) async {}
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        let size = bounds.size
        let side = min(size.width, size.height)
        let config = Self.configs.first(where: { $0.side <= side }) ?? Self.configs.last ?? .zero
        let font = UIKitFontBuilder.uiKitFont(name: .inter, size: config.fontSize, weight: .semibold)
        
        let textSize = NSString(string: text)
            .size(withAttributes: [.font: font])
        
        let textRect = CGRect(
            x: 0,
            y: (bounds.size.height - textSize.height) / 2,
            width: bounds.size.width,
            height: textSize.height
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        text.draw(
            with: textRect,
            options: [
                .usesLineFragmentOrigin,
                .usesFontLeading
            ],
            attributes: [
                .foregroundColor: UIColor.Text.white,
                .font: font,
                .paragraphStyle: paragraphStyle
            ],
            context: nil
        )
    }
}
