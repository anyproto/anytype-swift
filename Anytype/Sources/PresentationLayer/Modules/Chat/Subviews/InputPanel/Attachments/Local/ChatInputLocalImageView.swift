import SwiftUI

struct ChatInputLocalImageView: View {
    
    let contentsOfFile: String
    let onTapRemove: () -> Void
    
    // Prevent image creation for each view update
    @State private var image: UIImage?
    
    init(contentsOfFile: String, onTapRemove: @escaping () -> Void) {
        self.contentsOfFile = contentsOfFile
        self.onTapRemove = onTapRemove
        self._image = State(initialValue: UIImage(contentsOfFile: contentsOfFile))
    }
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .onChange(of: contentsOfFile) { _, newValue in
            image = UIImage(contentsOfFile: contentsOfFile)
        }
        .frame(width: 72, height: 72)
        .messageLinkStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}
