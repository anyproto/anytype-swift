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
            let side: CGFloat = side(size: reader.size)
            CachedAsyncImage(
                url: ImageMetadata(id: imageId, width: .width(side)).contentUrl
            ) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LoadingPlaceholderIconView()
            }
            .if(square) {
                $0.frame(width: side, height: side)
            }
        }
    }
    
    private func side(size: CGSize) -> CGFloat {
        switch side {
        case .width:
            return size.width
        case .height:
            return size.height
        case .minSide:
            return min(size.width, size.height)
        }
    }
}
