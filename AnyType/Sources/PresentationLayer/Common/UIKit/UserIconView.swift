import SwiftUI
import UIKit


struct UserIconView: View {
    var image: UIImage?
    var name: String
    
    var body: some View {
        VStack(spacing: 0) {
            if let value = self.image {
                Image(uiImage: value)
                    .renderingMode(.original)
                    .resizable().aspectRatio(contentMode: .fill)
            } else {
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
            
            UserIconView(
                image: UIImage(named: "mainAuthBackground"),
                name: "Anton B"
            ).frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
}
