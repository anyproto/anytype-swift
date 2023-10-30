import Foundation
import UIKit

final class IconMaker {
    
    private struct HashData: Hashable {
        let icon: Icon
        let bounds: CGRect
        let iconContext: IconContext
        let placeholder: Bool
        
        var hashString: String {
            return "\(hashValue)"
        }
    }
    
    let icon: Icon
    let size: CGSize
    let iconContext: IconContext
    
    private let bounds: CGRect
    private var painter: IconPainter?
    private let imageStorage = ImageStorage.shared
    
    init(icon: Icon, size: CGSize, iconContext: IconContext = IconContext(isEnabled: true)) {
        self.icon = icon
        self.size = size
        self.iconContext = iconContext
        let side = min(size.width, size.height)
        self.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        self.painter = createPainter(icon: icon)
    }
    
    @MainActor
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
    
    func makeFromCache() -> UIImage? {
        let hash = HashData(icon: icon, bounds: bounds, iconContext: iconContext, placeholder: false)
        if let image = imageStorage.image(forKey: hash.hashString) {
            return image
        }
        return nil
    }
    
    @MainActor
    func make() async -> UIImage {
        if let image = makeFromCache() {
            return image
        }
        
        await painter?.prepare(bounds: bounds)
        let image = UIImage.generateDynamicImage {
            let renderer = UIGraphicsImageRenderer(size: size, format: .preferred())
            return renderer.image { ctx in
                painter?.draw(bounds: bounds, context: ctx.cgContext, iconContext: iconContext)
            }
        }
        
        let hash = HashData(icon: icon, bounds: bounds, iconContext: iconContext, placeholder: false)
        imageStorage.saveImage(image, forKey: hash.hashString)
        
        return image
    }
    
    // MARK: - Private func
    
    private func createPainter(icon: Icon) -> IconPainter? {
        switch icon {
        case .object(let ObjectIcon):
            switch ObjectIcon {
            case .basic(let imageId):
                return SquareIconPainter(contentPainter: contentPainter(.imageId(imageId)))
            case .profile(let profile):
                switch profile {
                case .imageId(let imageId):
                    return CircleIconPainter(contentPainter: contentPainter(.imageId(imageId)))
                case .character(let c):
                    return CircleIconPainter(contentPainter: contentPainter(.char(String(c))))
                }
            case .emoji(let emoji):
                return SquircleIconPainter(contentPainter: contentPainter(.char(emoji.value)))
            case .bookmark(let imageId):
                return SmallImageIdPainter(imageId: imageId)
            case .space(let space):
                switch space {
                case .character(let c):
                    return SquareIconPainter(contentPainter: contentPainter(.char(String(c))))
                case .gradient(let gradientId):
                    return SquareGradientIconPainter(gradientId: gradientId.rawValue)
                }
            case .todo(let checked):
                return checked ? contentPainter(.asset(.TaskLayout.done)) : contentPainter(.asset(.TaskLayout.empty))
            case .placeholder(let c):
                let char = c.map { String($0) } ?? ""
                return SquareIconPainter(contentPainter: contentPainter(.char(char)))
            }
        case .asset(let imageAsset):
            return contentPainter(.asset(imageAsset))
        case .image(let uIImage):
            return contentPainter(.image(uIImage))
        case .square(let content):
            return SquareIconPainter(contentPainter: contentPainter(content))
        case .cycle(let content):
            return CircleIconPainter(contentPainter: contentPainter(content))
        case .squircle(let content):
            return SquircleIconPainter(contentPainter: contentPainter((content)))
        }
    }
    
    private func contentPainter(_ iconContent: Icon.Content) -> IconPainter {
        switch iconContent {
        case .char(let c):
            return CharIconPainter(text: String(c))
        case .asset(let imageAsset):
            return AssetIconPainter(asset: imageAsset)
        case .image(let uIImage):
            return ImageDataIconPainter(image: uIImage)
        case .imageId(let imageId):
            return ImageIdPainter(imageId: imageId)
        }
    }
}
