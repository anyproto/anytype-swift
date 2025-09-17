import Foundation
import SwiftUI
import Services

struct IconView: View {
    
    let icon: Icon?
    let assetColor: Color
    let asseetDisabledColor: Color
        
    init(icon: Icon?, assetColor: Color = .Control.secondary, asseetDisabledColor: Color = .Control.tertiary) {
        self.icon = icon
        self.assetColor = assetColor
        self.asseetDisabledColor = asseetDisabledColor
    }
    
    var body: some View {
        switch icon {
        case .object(let objectIcon):
            ObjectIconView(icon: objectIcon)
        case .asset(let imageAsset):
            Image(asset: imageAsset)
                .dynamicForegroundStyle(color: assetColor, disabledColor: asseetDisabledColor)
        case .image(let uIImage):
            Image(uiImage: uIImage)
                .dynamicForegroundStyle(color: assetColor, disabledColor: asseetDisabledColor)
        case .url(let url):
            ImageUrlIconView(url: url)
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
