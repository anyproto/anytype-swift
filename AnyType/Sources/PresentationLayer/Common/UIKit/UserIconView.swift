import SwiftUI
import UIKit


struct UserIconView: View {
    var image: UIImage?
    var name: String
    
    private var chosenInitialGlyph: Character {
        self.name.first ?? "👻"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let value = self.image {
                Image(uiImage: value)
                    .renderingMode(.original)
                    .resizable().aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color.gray
                    AnytypeText(String(chosenInitialGlyph), style: .title)
                        .foregroundColor(Color.white)
                }
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
