import Foundation
import SwiftUI
import Services

struct IconView: View {
    
    let icon: Icon?
    
    var body: some View {
        switch icon {
        case .object(let objectIcon):
            ObjectIconView(icon: objectIcon)
        case .asset(let imageAsset):
            Image(asset: imageAsset)
                .buttonDynamicForegroundStyle()
        case .image(let uIImage):
            Image(uiImage: uIImage)
                .buttonDynamicForegroundStyle()
        case nil:
            EmptyView()
        }
    }
}

extension IconView {
    init(asset: ImageAsset) {
        self = IconView(icon: .asset(asset))
    }
    
    init(object: ObjectIcon) {
        self = IconView(icon: .object(object))
    }
    
    init(uiImage: UIImage) {
        self = IconView(icon: .image(uiImage))
    }
}
