import SwiftUI
import AVKit
import Services

struct MessageVideoView: View {
    
    let url: URL?
    
    // Prevent image creation for each view update
    @State private var image: UIImage?
    @StateObject private var model = MessageLinkVideoViewModel()
    
    init(url: URL?) {
        self.url = url
        self._image = State(initialValue: nil)
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                Color.black.opacity(0.2)
                Image(asset: .X32.video)
                    .foregroundStyle(Color.white)
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .task(id: [url?.hashValue ?? 0, reader.size.width.hashValue].hashValue) {
                guard let url, reader.size != .zero else { return }
                image = await model.preview(for: url, size: reader.size)
            }
        }
    }
}

@MainActor
private final class MessageLinkVideoViewModel: ObservableObject {
    
    @Injected(\.videoPreviewStorage)
    private var videoPreviewStorage: any VideoPreviewStorageProtocol
    
    func preview(for url: URL, size: CGSize) async -> UIImage? {
        try? await videoPreviewStorage.preview(url: url, size: size)
    }
}

extension MessageVideoView {
    init(details: MessageAttachmentDetails) {
        self = MessageVideoView(url: ContentUrlBuilder.fileUrl(fileId: details.id))
    }
}
