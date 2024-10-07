import SwiftUI

struct MessageLinkLocalImageView: View {
    
    let contentsOfFile: String
    
    // Prevent image creation for each view update
    @State private var image: UIImage?
    
    init(contentsOfFile: String) {
        self.contentsOfFile = contentsOfFile
        self._image = State(initialValue: UIImage(contentsOfFile: contentsOfFile))
    }
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onChange(of: contentsOfFile) { newValue in
            image = UIImage(contentsOfFile: contentsOfFile)
        }
    }
}
