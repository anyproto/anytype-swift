import SwiftUI
import UIKit


struct UserIconView: View {
    var image: UIImage?
    var color: UIColor?
    var name: String
    
    private func defaultColor() -> UIColor {
        return .black
    }
    
    private var chosenColor: UIColor {
        self.color ?? self.defaultColor()
    }
    
    private func defaultInitialGlyph() -> Character {
        return "A"
    }
    
    private var chosenInitialGlyph: Character {
        self.name.first ?? self.defaultInitialGlyph()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let value = self.image {
                Image(uiImage: value)
                    .renderingMode(.original)
                    .resizable().correctAspectRatio(ofImage: value, contentMode: .fill)
            } else {
                ZStack {
                    Color(self.chosenColor)
                    Text(String(self.chosenInitialGlyph))
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color.white)
                }
            }
        }
        .clipShape(Circle())
    }
}

struct SimpleViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserIconView(image: UIImage(named: "logo-sign-part-mobile"), color: nil, name: "Anton B")
        }
    }
}
