import Foundation
import SwiftUI
import CachedAsyncImage
import UIKit

struct ObjectHeaderCoverView: View {
    
    let objectCover: ObjectHeaderCoverType
    let fitImage: Bool
    
    var body: some View {
        GeometryReader { reader in
            return Group {
                switch objectCover {
                case .cover(let cover):
                    documentCover(cover, reader.size)
                case .preview(let previewType):
                    previewView(previewType, reader.size)
                }
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .clipped()
        }
        .id(objectCover.hashValue)
    }
    
    @ViewBuilder
    private func documentCover(_ cover: DocumentCover, _ size: CGSize) -> some View {
        switch cover {
        case let .imageId(imageId):
            imageWithId(imageId, size, fitImage)
        case let .color(color):
            colorView(color, size)
        case let .gradient(gradientColor):
            gradientView(gradientColor, size)
        }
    }
    
    private func imageWithId(_ imageId: String, _ size: CGSize, _ fitImage: Bool) -> some View {
        CachedAsyncImage(
            url: ImageMetadata(id: imageId, side: .width(size.width)).contentUrl
        ) { image in
            image.resizable()
                .if(fitImage) {
                    $0.scaledToFit()
                } else: {
                    $0.scaledToFill()
                }

        } placeholder: {
            Image(uiImage: UIImage()) // EmptyView breaks loading
        }
    }
    
    private func colorView(_ color: UIColor, _ size: CGSize) -> some View {
        color.suColor
    }
    
    private func gradientView(_ gradient: GradientColor, _ size: CGSize) -> some View {
        gradient.asLinearGradient()
    }

    private func previewView(_ previewType: ObjectHeaderCoverPreviewType, _ size: CGSize) -> some View {
        ZStack(alignment: .center) {
            switch previewType {
            case .remote(let url):
                CachedAsyncImage(url: url)
                    { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(uiImage: UIImage()) // EmptyView breaks loading
                    }
            case .image(let image):
                if let image {
                    Image(uiImage: image)
                }
            }
            
            ActivityIndicator(style: .medium)
        }
    }
}
