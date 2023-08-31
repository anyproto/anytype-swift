import Foundation
import SwiftUI

struct IconView: View {
    
    let icon: Icon?
    
    @State private var task: Task<Void, Never>?
    @State private var size: CGSize?
    @State private var placeholderImage: UIImage?
    @State private var image: UIImage?
    
    @Environment(\.isEnabled) private var isEnable
    @Environment(\.redactionReasons) var redactionReasons
    
    // MARK: - Public properties
    
    var body: some View {
        content
        .readSize { newSize in
            size = newSize
        }
        .onChange(of: isEnable) { _ in
            updateIcon()
        }
        .onChange(of: size) { _ in
            updateIcon()
        }
        .onChange(of: icon) { icon in
            // Icon field from struct contains old value
            updateIcon(icon)
            
        }
        .frame(idealWidth: 30, idealHeight: 30) // Default frame
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
    
    private func updateIcon(_ newIcon: Icon? = nil) {
        task?.cancel()
        guard let icon = newIcon ?? icon, let size else {
            placeholderImage = nil
            image = nil
            return
        }
        task = Task { @MainActor in
            let maker = IconMaker(icon: icon, size: size, iconContext: IconContext(isEnabled: isEnable))
            placeholderImage = maker.makePlaceholder()
            image = await maker.make()
        }
    }
}
