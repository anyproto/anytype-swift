import Foundation
import SwiftUI
import CachedAsyncImage

enum ImageIdIconSide {
    case width
    case height
    case minSide
}

struct ImageIdIconView: View {
    
    let imageId: String
    let square: Bool
    let side: ImageIdIconSide
    
    init(imageId: String, square: Bool = true, side: ImageIdIconSide = .minSide) {
        self.imageId = imageId
        self.square = square
        self.side = side
    }
    
    var body: some View {
        GeometryReader { reader in
            CachedAsyncImage(
                url: ImageMetadata(id: imageId, side: side(size: reader.size)).contentUrl
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
        case .height:
            return .height(size.height)
        case .minSide:
            return .width(min(size.width, size.height))
        }
    }
}
