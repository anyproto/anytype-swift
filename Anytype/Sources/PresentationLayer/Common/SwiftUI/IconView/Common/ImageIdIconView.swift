import Foundation
import SwiftUI

struct ImageIdIconView: View {
    
    let imageId: String
    
    var body: some View {
        GeometryReader { reader in
            let side = min(reader.size.width, reader.size.height)
            AsyncImage(
                url: ImageMetadata(id: imageId, width: .width(side)).contentUrl
            ) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(uiImage: UIImage(ciImage: .empty()))
                    .resizable()
                    .scaledToFill()
                    .redacted(reason: .placeholder)
            }
            .frame(width: side, height: side)
        }
    }
}
