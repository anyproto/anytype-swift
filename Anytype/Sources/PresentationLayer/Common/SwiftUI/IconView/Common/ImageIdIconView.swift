import Foundation
import SwiftUI
import CachedAsyncImage

struct ImageIdIconView: View {
    
    let imageId: String
    
    var body: some View {
        GeometryReader { reader in
            let side = min(reader.size.width, reader.size.height)
            CachedAsyncImage(
                url: ImageMetadata(id: imageId, width: .width(side)).contentUrl
            ) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LoadingPlaceholderIconView()
            }
            .frame(width: side, height: side)
        }
    }
}
