import Foundation
import SwiftUI

struct IconView: View {
    
    let icon: Icon?
    
    var body: some View {
        switch icon {
        case .object(let objectIcon):
            ObjectIconView(icon: objectIcon)
        case .asset(let imageAsset):
            Image(asset: imageAsset)
                .buttonDynamicForegroundColor()
        case .image(let uIImage):
            Image(uiImage: uIImage)
                .buttonDynamicForegroundColor()
        case nil:
            EmptyView()
        }
    }
}
