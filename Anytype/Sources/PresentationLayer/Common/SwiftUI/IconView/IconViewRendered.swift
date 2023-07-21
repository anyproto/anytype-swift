import Foundation
import SwiftUI

struct IconView: View {
    
    let icon: ObjectIconImage
    
    @State private var task: Task<Void, Never>?
    @State private var size: CGSize = .zero
    @State private var image: UIImage?
    
    @Environment(\.isEnabled) private var isEnable
    
    // MARK: - Public properties
    
    var body: some View {
        ZStack {
            Color.clear.readSize { newSize in
                size = newSize
            }
            if let image {
                Image(uiImage: image)
            }
        }
        .onChange(of: isEnable) { _ in
            updateIcon()
        }
        .onChange(of: size) { _ in
            updateIcon()
        }
        .frame(idealWidth: 30, idealHeight: 30) // Default frame
    }
    
    private func updateIcon() {
        task?.cancel()
        task = Task {
            let maker = IconMaker(icon: icon, size: size, iconContext: IconContext(isEnabled: isEnable))
            image = maker.makePlaceholder()
            image = await maker.make()
        }
    }
}
