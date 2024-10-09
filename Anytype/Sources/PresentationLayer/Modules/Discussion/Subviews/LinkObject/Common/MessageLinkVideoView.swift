import SwiftUI
import AVKit
import Services

struct MessageLinkVideoView: View {
    
    let url: URL?
    
    // Prevent image creation for each view update
    @State private var image: UIImage?
    @StateObject private var model = MessageLinkVideoViewModel()
    
    init(url: URL?) {
        self.url = url
        self._image = State(initialValue: nil)
    }
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            Color.black.opacity(0.2)
            Image(asset: .X32.video)
                .foregroundStyle(Color.white)
        }
        .task(id: url) {
            guard let url else { return }
            image = await model.preview(for: url)
        }
    }
}

private final class MessageLinkVideoViewModel: ObservableObject {
    
    @Injected(\.videoPreviewStorage)
    private var videoPreviewStorage: any VideoPreviewStorageProtocol
    
    func preview(for url: URL) async -> UIImage? {
        await videoPreviewStorage.preview(url: url)
    }
}

extension MessageLinkVideoView {
    init(details: MessageAttachmentDetails) {
        self = MessageLinkVideoView(url: ContentUrlBuilder.fileUrl(fileId: details.id))
    }
}
