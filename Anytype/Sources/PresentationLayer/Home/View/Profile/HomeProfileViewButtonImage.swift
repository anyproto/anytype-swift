import SwiftUI
import SwiftUIVisualEffects

struct HomeProfileViewButtonImage<Image: View>: View {
    let image: Image
    
    var body: some View {
        image.frame(width: 52, height: 52)
            .background(BlurEffect())
            .blurEffectStyle(.systemMaterial)
            .clipShape(Circle())
    }
}

struct HomeProfileViewButtonImage_Previews: PreviewProvider {
    static var previews: some View {
        HomeProfileViewButtonImage(image: Image.main.search)
            .previewLayout(.sizeThatFits)
    }
}
