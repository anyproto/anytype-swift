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
    
    init(objectType: ObjectType) {
        if let emoji = objectType.iconEmoji {
            self = IconView(icon: .object(.emoji(emoji)))
        } else {
            self = IconView(icon: .object(.empty(.objectType)))
        }
    }
}
