import SwiftUI
import SwiftUIVisualEffects

struct HomeProfileViewButtonImage<Image: View>: View {
    
    @Environment(\.redactionReasons) private var reasons
    let image: Image
    
    var body: some View {
        Group {
            if reasons.isEmpty {
                image
            } else {
                Spacer()
            }
        }
        .frame(width: 52, height: 52)
        .background(BlurEffect())
        .blurEffectStyle(.systemMaterial)
        .clipShape(Circle())
    }
}

struct HomeProfileViewButtonImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HomeProfileViewButtonImage(image: Image.main.search)
            HomeProfileViewButtonImage(image: Image.main.search)
                .redacted(reason: .placeholder)
        }
        .previewLayout(.sizeThatFits)
    }
}
