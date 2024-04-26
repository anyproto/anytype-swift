import Foundation
import SwiftUI

struct IconView: View {
    
    let icon: Icon?
    
    @State private var task: Task<Void, Never>?
    @State private var size: CGSize?
    @State private var placeholderImage: UIImage?
    @State private var image: UIImage?
    @State private var id = UUID()
    
    @Environment(\.isEnabled) private var isEnable
    @Environment(\.redactionReasons) var redactionReasons
    
    // MARK: - Public properties
    
    var body: some View {
        content
        .readSize { newSize in
            size = newSize
        }
        .onChange(of: isEnable) { isEnable in
            updateIcon(isEnable: isEnable)
        }
        .onChange(of: size) { size in
            updateIcon(size: size)
        }
        .onChange(of: icon) { icon in
            // Icon field from struct contains old value
            updateIcon(icon)
        }
        .frame(idealWidth: 30, idealHeight: 30) // Default frame
        .id(id)
    }
    
    // Root view should be a image view for apply initial frame.
    // Don't use a viewbuilder, because view builder make a container
    private var content: Image {
        if redactionReasons.contains(.placeholder) {
            return systemPlaceholder
        } else if let image {
            return Image(uiImage: image)
        } else if let placeholderImage {
            return Image(uiImage: placeholderImage)
        } else {
            return systemPlaceholder
        }
    }
    
    private var systemPlaceholder: Image {
        // Empty image for native placeholder
        Image(uiImage: UIImage())
            .resizable()
    }
    
    private func updateIcon(_ newIcon: Icon? = nil, size newSize: CGSize? = nil, isEnable newIsEnable: Bool? = nil) {
        task?.cancel()
        guard let icon = newIcon ?? icon, let size = newSize ?? size else {
            placeholderImage = nil
            image = nil
            return
        }
        let isEnable = newIsEnable ?? isEnable
        let maker = IconMaker(icon: icon, size: size, iconContext: IconContext(isEnabled: isEnable))
        if let imageFromCache = maker.makeFromCache() {
            image = imageFromCache
        } else {
            task = Task { @MainActor in
                placeholderImage = maker.makePlaceholder()
                image = await maker.make()
            }
        }
    }
}
