import Foundation
import UIKit

final class IconMaker {
    
    private struct HashData: Hashable {
        let icon: ObjectIconImage
        let bounds: CGRect
        let iconContext: IconContext
        let placeholder: Bool
        
        var hashString: String {
            return "\(hashValue)"
        }
    }
    
    let icon: ObjectIconImage
    let size: CGSize
    let iconContext: IconContext
    
    private let bounds: CGRect
    private let painter: IconPainter?
    private let imageStorage = ImageStorage.shared
    
    init(icon: ObjectIconImage, size: CGSize, iconContext: IconContext = IconContext(isEnabled: true)) {
        self.icon = icon
        self.size = size
        self.iconContext = iconContext
        let side = min(size.width, size.height)
        self.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        self.painter = IconMaker.createPainter(icon: icon)
    }
    
    func makePlaceholder() -> UIImage {
        let hash = HashData(icon: icon, bounds: bounds, iconContext: iconContext, placeholder: true)
        if let image = imageStorage.image(forKey: hash.hashString) {
            return image
        }
        
        let image = UIImage.generateDynamicImage {
            let renderer = UIGraphicsImageRenderer(size: size, format: .preferred())
            return renderer.image { ctx in
                painter?.drawPlaceholder(bounds: bounds, context: ctx.cgContext, iconContext: iconContext)
            }
        }
        
        imageStorage.saveImage(image, forKey: hash.hashString)
        return image
    }
    
    func make() async -> UIImage {
        let hash = HashData(icon: icon, bounds: bounds, iconContext: iconContext, placeholder: false)
        if let image = imageStorage.image(forKey: hash.hashString) {
            return image
        }
        
        await painter?.prepare(bounds: bounds)
        let image = UIImage.generateDynamicImage {
            let renderer = UIGraphicsImageRenderer(size: size, format: .preferred())
            return renderer.image { ctx in
                painter?.draw(bounds: bounds, context: ctx.cgContext, iconContext: iconContext)
            }
        }
        imageStorage.saveImage(image, forKey: hash.hashString)
        return image
    }
    
    // MARK: - Private func
    
    private static func createPainter(icon: ObjectIconImage) -> IconPainter? {
        switch icon {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic(let imageId):
                return SquareIconPainter(contentPainter: ImageIdPainter(imageId: imageId))
            case .profile(let profile):
                switch profile {
                case .imageId(let imageId):
                    return CircleIconPainter(contentPainter: ImageIdPainter(imageId: imageId))
                case .character(let c):
                    return CircleIconPainter(contentPainter: CharIconPainter(text: String(c)))
                case .gradient(let gradientId):
                    return GradientIdIconPainter(gradientId: gradientId.rawValue)
                }
            case .emoji(let emoji):
                return SquircleIconPainter(contentPainter: CharIconPainter(text: emoji.value))
            case .bookmark(let imageId):
                return SmallImageIdPainter(imageId: imageId)
            case .space(let space):
                switch space {
                case .character(let c):
                    return SquareDynamicIconPainter(contentPainter: CharIconPainter(text: String(c)))
                case .gradient(let gradientId):
                    return SquareGradientIconPainter(gradientId: gradientId.rawValue)
                }
            }
        case .todo(let checked):
            return checked ? AssetIconPainter(asset: .TaskLayout.done) : AssetIconPainter(asset: .TaskLayout.empty)
        case .placeholder(let c):
            return SquareDynamicIconPainter(contentPainter: CharIconPainter(text: String(c!)))
        case .imageAsset(let imageAsset):
            return AssetIconPainter(asset: imageAsset)
        case .image(let uIImage):
            return ImageDataIconPainter(image: uIImage)
        }
    }
}
