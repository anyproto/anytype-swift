import SwiftUI
import UIKit

extension UserIconView {
    enum IconType {
        case image(ImageType)
        case placeholder(Character?)
    }
    
    enum ImageType {
        case local(image: UIImage)
        case middleware(imageId: String)
    }
}

struct UserIconView: View {
    let icon: IconType
    
    var body: some View {
        Group {
            switch icon {
            case let .image(image):
                makeIconImageView(image)
            case let .placeholder(character):
                AnytypeText(
                    character.flatMap { String($0) } ?? "",
                    name: .graphik,
                    size: 45,
                    weight: .regular
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.black)
                .blendMode(.overlay)
                .background(HomeBackgroundBlurView())
            }
        }
        .clipShape(Circle())
    }
    
    private func makeIconImageView(_ image: ImageType) -> some View {
        Group {
            switch image {
            case let .local(image: image):
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable().aspectRatio(contentMode: .fill)
            case let .middleware(imageId: imageId):
                AsyncImage(
                    imageId: imageId,
                    parameters: ImageParameters(width: .thumbnail)
                )
                .aspectRatio(contentMode: .fill)
            }
        }
    }
    
}


struct SimpleViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserIconView(
                icon: .placeholder("A")
            )
            .frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
}
