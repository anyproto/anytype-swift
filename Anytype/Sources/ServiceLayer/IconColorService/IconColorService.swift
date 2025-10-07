import Foundation
import SwiftUI
import Services
import Factory
import DesignKit

protocol IconColorServiceProtocol: AnyObject {
    func color(spaceId: String) -> AsyncStream<Color>
}

final class IconColorService: IconColorServiceProtocol, Sendable {
    
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    private let imageCacher = CachedAsyncImageCache.default
    
    func color(spaceId: String) -> AsyncStream<Color> {
        AsyncStream { continuation in
            let task = Task {
                for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
                    if let color = try? await color(icon: spaceView.objectIconImage) {
                        continuation.yield(color)
                    }
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    // MARK: - Private
    
    private func color(icon: Icon) async throws -> Color {
        switch icon {
        case .object(let objectIcon):
            return try await object(icon: objectIcon)
        case .asset, .image, .url:
            throw CommonError.undefined
        }
    }
    
    private func object(icon: ObjectIcon) async throws -> Color {
        switch icon {
        case .space(let spaceIcon):
            switch spaceIcon {
            case let .imageId(imageId, _, iconOption, _):
                do {
                    guard let url = ImageMetadata(id: imageId, side: .width(10)).contentUrl else {
                        throw CommonError.undefined
                    }
                    let image = try await imageCacher.loadImage(from: url)
                    let color = try image.averageColor()
                    return optimizeColor(color).suColor
                } catch {
                    let color = IconColorStorage.iconBackgroundColor(iconOption: iconOption)
                    return optimizeColor(UIColor(color)).suColor
                }
            case .name(_, let iconOption, _):
                let color = IconColorStorage.iconBackgroundColor(iconOption: iconOption)
                return optimizeColor(UIColor(color)).suColor
            case .localPath(let path, _):
                guard let image = UIImage(contentsOfFile: path) else {
                    throw CommonError.undefined
                }
                let color = try image.averageColor()
                return optimizeColor(color).suColor
            }
        default:
            throw CommonError.undefined
        }
    }
    
    private func optimizeColor(_ color: UIColor) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        
        if saturation < 0.1 {
            let lightColor = UIColor(hue: hue, saturation: saturation, brightness: 0.5, alpha: 1)
            let darkColor = UIColor(hue: hue, saturation: saturation, brightness: 0.5, alpha: 1)
            return UIColor(light: lightColor, dark: darkColor)
        } else {
            let lightColor = UIColor(hue: hue, saturation: 0.4, brightness: 0.8, alpha: 1)
            let darkColor = UIColor(hue: hue, saturation: 0.4, brightness: 0.2, alpha: 1)
            return UIColor(light: lightColor, dark: darkColor)
        }
    }
}
