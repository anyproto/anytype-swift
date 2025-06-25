import Foundation
import SwiftUI

enum ImageIdIconSide {
    case width
    case original
}

struct ImageIdIconView: View {
    
    let imageId: String
    let square: Bool
    let side: ImageIdIconSide
    
    init(imageId: String, square: Bool = true, side: ImageIdIconSide = .width) {
        self.imageId = imageId
        self.square = square
        self.side = side
    }
    
    var body: some View {
        GeometryReader { reader in
            ToggleCachedAsyncImage(
                url: ImageMetadata(id: imageId, side: side(size: reader.size)).contentUrl,
                urlCache: .anytypeImages
            ) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LoadingPlaceholderIconView()
            }
            .if(square) {
                let side = min(reader.size.width, reader.size.height)
                return $0.frame(width: side, height: side)
            } else: {
                return $0.frame(width: reader.size.width, height: reader.size.height)
            }
        }
    }
    
    private func side(size: CGSize) -> ImageSide {
        switch side {
        case .width:
            return .width(size.width)
        case .original:
            return .original
        }
    }
}
