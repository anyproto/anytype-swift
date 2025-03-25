import SwiftUI

struct LocalIconView: View {
    
    private let image: UIImage?
    
    init(contentsOfFile: String) {
        self.image = UIImage(contentsOfFile: contentsOfFile)
    }
    
    var body: some View {
        if let image {
            GeometryReader { reader in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: reader.size.width, height: reader.size.height)
            }
        } else {
            LoadingPlaceholderIconView()
        }
    }
}
