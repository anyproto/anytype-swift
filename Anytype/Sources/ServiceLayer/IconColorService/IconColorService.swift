import Foundation
import SwiftUI
import Services
import Kingfisher
import Factory

protocol IconColorServiceProtocol: AnyObject {
    func color(spaceId: String) -> AsyncStream<Color>
}

final class IconColorService: IconColorServiceProtocol, Sendable {
    
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    
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
        case .asset, .image:
            throw CommonError.undefined
        }
    }
    
    private func object(icon: ObjectIcon) async throws -> Color {
        switch icon {
        case .space(let spaceIcon):
            switch spaceIcon {
            case .imageId(let imageId):
                guard let url = ImageMetadata(id: imageId, width: .width(10)).contentUrl else {
                    throw CommonError.undefined
                }
                let image = try await KingfisherManager.shared.retrieveImageAsync(with: url).image
                let color = try image.averageColor()
                return optimizeColor(color).suColor
            case .name(_, let iconOption):
                let color = IconColorStorage.iconColor(iconOption: iconOption)
                return optimizeColor(UIColor(color)).suColor
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
            let lightColor = UIColor(hue: hue, saturation: 0.4, brightness: 1, alpha: 1)
            let darkColor = UIColor(hue: hue, saturation: 0.4, brightness: 0.2, alpha: 1)
            return UIColor(light: lightColor, dark: darkColor)
        }
    }
}
