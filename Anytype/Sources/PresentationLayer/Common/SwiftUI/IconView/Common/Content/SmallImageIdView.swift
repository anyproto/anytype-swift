import SwiftUI
import AnytypeCore

struct SmallImageIdView: View {

    let imageId: String
    
    @State private var url: URL?
    @State private var size: CGSize = .zero
    
    var body: some View {
        SquareView { _ in
            content
        }
    }
    
    private var content: some View {
        AsyncImage(url: url, scale: UIScreen.main.scale) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .frame(maxWidth: 28, maxHeight: 28)
            }
            // TODO: Handle error. Add placeholder.
        }
        .readSize { size in
            let imageMetadata = ImageMetadata(id: imageId, width: .width(size.width))
            guard let url = imageMetadata.contentUrl else {
                anytypeAssertionFailure("Url is nil")
                return
            }
            self.url = url
            self.size = size
        }
    }
}
