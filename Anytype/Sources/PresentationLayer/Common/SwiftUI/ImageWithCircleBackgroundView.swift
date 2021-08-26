import SwiftUI

struct ImageWithCircleBackgroundView: View {
    var image: Image
    var backgroundColor: UIColor? // TODO: Remove it.
    var backgroundImage: UIImage?
    
    var body: some View {
        ZStack {
            chosenImage()
            image
        }
        .clipShape(Circle())
    }
    
    private func aspectRatio() -> CGFloat {
        if let image = self.backgroundImage, image.size.height != 0, image.size.width != 0 {
            let width = image.size.width
            let height = image.size.height
            return width < height ? width / height : height / width
        }
        
        // If any dimension equal zero, well...
        // Don't do anything.
        return 0
    }
    
    private func chosenImage() -> some View {
        Group {
            if let value = self.backgroundColor {
                Color(value)
            }
            else if let value = self.backgroundImage {
                Image(uiImage: value)
                    .renderingMode(.original)
                    .resizable()
                    .correctAspectRatio(ofImage: value, contentMode: .fill)
            }
            else {
                Color(.clear)
            }
        }
    }
}

struct ImageWithCircleBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            Group {
                ImageWithCircleBackgroundView(image: .logo, backgroundColor: .secondarySystemBackground)
                    .frame(width: 200, height: 200)
                
                ImageWithCircleBackgroundView(image: .logo, backgroundImage: UIImage(named: "splashLogo"))
                    .frame(width: 150, height: 150)
            }
        }.background(Color.blue)
    }
}
