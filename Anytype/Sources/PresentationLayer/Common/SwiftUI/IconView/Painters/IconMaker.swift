import Foundation
import UIKit

final class IconMaker {
    
    let icon: ObjectIconImage
    let size: CGSize
    let iconContext: IconContext
    
    private let bounds: CGRect
    private let painter: IconPainter?
    
    init(icon: ObjectIconImage, size: CGSize, iconContext: IconContext = IconContext(isEnabled: true)) {
        self.icon = icon
        self.size = size
        self.iconContext = iconContext
        let side = min(size.width, size.height)
        self.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        self.painter = IconMaker.createPainter(icon: icon)
    }
    
    func makePlaceholder() -> UIImage {
        return UIImage.generateDynamicImage {
            let renderer = UIGraphicsImageRenderer(size: size, format: .preferred())
            return renderer.image { ctx in
                painter?.drawPlaceholder(bounds: bounds, context: ctx.cgContext, iconContext: iconContext)
            }
        }
    }
    
    func make() async -> UIImage {
        await painter?.prepare(bounds: bounds)
        return UIImage.generateDynamicImage {
            let renderer = UIGraphicsImageRenderer(size: size, format: .preferred())
            return renderer.image { ctx in
                painter?.draw(bounds: bounds, context: ctx.cgContext, iconContext: iconContext)
            }
        }
    }
    
    // MARK: - Private func
    
    private static func createPainter(icon: ObjectIconImage) -> IconPainter? {
        switch icon {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic(let imageId):
                return SquareImageIdPainter(imageId: imageId)
            case .profile(let profile):
                switch profile {
                case .imageId(let imageId):
                    return CircleImageIdPainter(imageId: imageId)
                case .character(let c):
                    return CircleCharIconPainter(text: String(c))
                case .gradient(let gradientId):
                    return GradientIdIconPainter(gradientId: gradientId.rawValue)
                }
            case .emoji(let emoji):
                return EmojiIconPainter(text: emoji.value)
            case .bookmark(let imageId):
                return SmallImageIdPainter(imageId: imageId)
            case .space(let space):
                switch space {
                case .character(let c):
                    return SquareCharIconPainter(text: String(c))
                case .gradient(let gradientId):
                    return SquareGradientIconPainter(gradientId: gradientId.rawValue)
                }
            }
        case .todo(let checked):
            return TodoIconPainter(checked: checked)
        case .placeholder(let character):
            return SquareCharIconPainter(text: String(character!))
        case .imageAsset(let imageAsset):
            return AssetIconPainter(asset: imageAsset)
        case .image(let uIImage):
            return ImageDataIconPainter(image: uIImage)
        }
    }
}
