import SwiftUI
import AVKit
import Services

struct MessageVideoView: View {
    
    let url: URL?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    
    @StateObject private var model = MessageLinkVideoViewModel()
    
    init(url: URL?, syncStatus: SyncStatus? = nil, syncError: SyncError? = nil) {
        self.url = url
        self.syncStatus = syncStatus
        self.syncError = syncError
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                if let image = model.image {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: reader.size.width, height: reader.size.height, alignment: .center)
                            .clipped()
                        MessageMediaUploadingStatus(
                            syncStatus: syncStatus,
                            syncError: syncError
                        ) {
                            MessageLoadingStateContainer {
                                Image(asset: .Controls.play)
                                    .foregroundStyle(Color.white)
                            }
                            .background(.black.opacity(0.5))
                        }
                    }
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
        self.init(
            url: ContentUrlBuilder.fileUrl(fileId: details.id),
            syncStatus: details.syncStatus,
            syncError: details.syncError
        )
    }
}


#Preview {
    MessageVideoView(url: nil, syncStatus: .syncing, syncError: nil)
        .frame(width: 100, height: 100)
}
