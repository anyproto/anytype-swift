import SwiftUI
import UIKit

extension UserIconView {
    enum ImageType {
        case local(image: UIImage)
        case middleware(imageId: String)
    }
}

struct UserIconView: View {
    var image: ImageType?
    var name: String?
    
    var body: some View {
        Group {
            if case .local(let image) = image {
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable().aspectRatio(contentMode: .fill)
            } else if case .middleware(let imageId) = image {
                AsyncImage(imageId: imageId, parameters: ImageParameters(width: .thumbnail))
                    .aspectRatio(contentMode: .fill)
            } else if let name = self.name {
                AnytypeText(
                    String(name.first ?? "👻"),
                    name: .graphik,
                    size: 45,
                    weight: .regular
                )
                .frame(width: 80, height: 80)
                .foregroundColor(.black)
                .blendMode(.overlay)
                .background(HomeBackgroundBlurView())
            } else {
                HomeBackgroundBlurView()
            }
        }
        .clipShape(Circle())
    }
}


struct SimpleViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserIconView(
                name: "Anton B"
            ).frame(width: 100, height: 100)
            
            UserIconView(
                name: ""
            ).frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
}
