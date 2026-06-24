import SwiftUI
import UIKit
import CoreImage
import AnytypeCore
import Services
import DesignKit

enum DashboardWallpaperMode: Hashable {
    case `default`
    case spaceHub
}

struct DashboardWallpaper: View {
    
    let mode: DashboardWallpaperMode
    let wallpaper: SpaceWallpaperType
    let spaceIcon: Icon?
    
    init(mode: DashboardWallpaperMode = .default, wallpaper: SpaceWallpaperType, spaceIcon: Icon?) {
        self.mode = mode
        self.wallpaper = wallpaper
        self.spaceIcon = spaceIcon
    }
    
    var body: some View {
            ZStack() {
                switch wallpaper {
                case .blurredIcon:
                    DashboardWallpaperBluerredIcon(mode: mode, spaceIcon: spaceIcon)
                        .equatable()
                case .color(let color):
                    Color(hex: color.data.hex).opacity(0.3)
                case .gradient(let gradient):
                    CoverGradientView(data: gradient.data)
                        .equatable()
                        .opacity(0.3)
                }
            }
            .ignoresSafeArea()
        
    }
}

private struct DashboardWallpaperBluerredIcon: View, Equatable {
    
    let mode: DashboardWallpaperMode
    let spaceIcon: Icon?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        switch spaceIcon {
        case let .object(.space(icon)):
            spaceIconView(spaceIcon: icon)
                .clipped()
                .opacity(iconOpacity)
                .overlay(colorOverlay)
        case let .object(.profile(icon)):
            profileIconView(profileIcon: icon)
                .clipped()
                .opacity(iconOpacity)
                .overlay(colorOverlay)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func spaceIconView(spaceIcon: ObjectIcon.Space) -> some View {
        switch spaceIcon {
        case let .name(_, iconOption, _):
            IconColorStorage.iconBackgroundColor(iconOption: iconOption)
        case let .imageId(imageId, _, iconOption, _):
            BlurredWallpaperImageView(imageId: imageId) {
                IconColorStorage.iconBackgroundColor(iconOption: iconOption)
            }
        case .localPath(let path, _):
            LocalIconView(contentsOfFile: path)
        }
    }

    @ViewBuilder
    private func profileIconView(profileIcon: ObjectIcon.Profile) -> some View {
        switch profileIcon {
        case let .imageId(imageId):
            BlurredWallpaperImageView(imageId: imageId) {
                Color.Shape.tertiary
            }
        case .name, .placeholder:
            Color.Shape.tertiary
        }
    }
    
    private var iconOpacity: CGFloat {
        switch mode {
        case .default:
            0.3
        case .spaceHub:
            colorScheme == .dark ? 0.5 : 0.3
        }
    }
    
    private var colorOverlay: some View {
        colorScheme == .dark ? Color.white.opacity(0.02) : Color.black.opacity(0.02)
    }
    
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.mode == rhs.mode && lhs.spaceIcon == rhs.spaceIcon
    }
}

// Renders the space-icon wallpaper as a blur that is computed ONCE per icon and cached
// process-wide, instead of a live `.blur` re-run on every mount (per-spaceId navigation,
// Space Hub per-card backgrounds). The icon source is already tiny (50px), so the blur is
// baked on the small bitmap and upscaled at display time, keeping cached bitmaps small.
private struct BlurredWallpaperImageView<Placeholder: View>: View {

    let imageId: String
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var blurred: UIImage?

    var body: some View {
        Group {
            if let blurred {
                Image(uiImage: blurred)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
            }
        }
        .task(id: imageId) {
            await loadBlurred()
        }
    }

    private func loadBlurred() async {
        if let cached = await BlurredWallpaperCache.shared.cached(imageId) {
            blurred = cached
            return
        }
        guard
            let url = ImageMetadata(id: imageId, side: .width(50)).contentUrl,
            let source = try? await CachedAsyncImageCache.default.loadImage(from: url)
        else { return }
        blurred = await BlurredWallpaperCache.shared.blurred(source: source, imageId: imageId)
    }
}

private actor BlurredWallpaperCache {

    static let shared = BlurredWallpaperCache()

    // Gaussian sigma in SOURCE pixels (the icon is fetched at 50px). Small values are plenty
    // once the result is upscaled to fill the screen. Tune visually against the previous
    // full-screen `.blur(radius: 32)` look.
    private static let sigma: Double = 4

    private let context = CIContext()
    private var cache: [String: UIImage] = [:]

    func cached(_ imageId: String) -> UIImage? {
        cache[imageId]
    }

    func blurred(source: UIImage, imageId: String) -> UIImage? {
        if let cached = cache[imageId] { return cached }
        let result = bake(source)
        if let result { cache[imageId] = result }
        return result
    }

    private func bake(_ source: UIImage) -> UIImage? {
        autoreleasepool {
            guard let input = CIImage(image: source) else { return nil }
            let extent = input.extent
            let output = input
                .clampedToExtent() // extend edge pixels so the blur has no transparent border (replaces the old .padding(-64))
                .applyingGaussianBlur(sigma: Self.sigma)
                .cropped(to: extent)
            guard let cgImage = context.createCGImage(output, from: extent) else { return nil }
            return UIImage(cgImage: cgImage)
        }
    }
}

struct DashboardWallpaper_Previews: PreviewProvider {
    static var previews: some View {
        DashboardWallpaper(wallpaper: .default, spaceIcon: .object(.space(.mock)))
    }
}
