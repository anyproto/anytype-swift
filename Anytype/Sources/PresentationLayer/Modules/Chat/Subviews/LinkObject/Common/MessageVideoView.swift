import SwiftUI
import AVKit
import Services

struct MessageVideoView: View {
    
    let url: URL?
    
    @StateObject private var model = MessageLinkVideoViewModel()
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                    Color.black.opacity(0.2)
                    Image(asset: .X32.video)
                        .foregroundStyle(Color.white)
                } else if model.hasError {
                    MessageAttachmentErrorIndicator()
                } else {
                    MessageAttachmentLoadingIndicator()
                }
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .task(id: [url?.hashValue ?? 0, reader.size.width.hashValue].hashValue) {
                guard let url, reader.size != .zero else { return }
                await model.updatePreview(for: url, size: reader.size)
            }
        }
    }
}

@MainActor
private final class MessageLinkVideoViewModel: ObservableObject {
    
    @Injected(\.videoPreviewStorage)
    private var videoPreviewStorage: any VideoPreviewStorageProtocol
    
    @Published var image: UIImage?
    @Published var hasError: Bool = false
    
    func updatePreview(for url: URL, size: CGSize) async {
        do {
            image = try await videoPreviewStorage.preview(url: url, size: size)
        } catch {
            hasError = true
        }
    }
}

extension MessageVideoView {
    init(details: MessageAttachmentDetails) {
        self = MessageVideoView(url: ContentUrlBuilder.fileUrl(fileId: details.id))
    }
}
