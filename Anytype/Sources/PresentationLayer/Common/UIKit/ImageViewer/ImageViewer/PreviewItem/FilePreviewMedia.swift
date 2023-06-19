import QuickLook
import Combine
import Services

final class FilePreviewMedia: NSObject, PreviewRemoteItem {
    // MARK: - PreviewRemoteItem
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    let file: BlockFile
    let blockId: BlockId

    // MARK: - QLPreviewItem
    var previewItemTitle: String? { "" }
    var previewItemURL: URL?

    private let fileDownloader = FileDownloader()

    init(file: BlockFile, blockId: BlockId) {
        self.file = file
        self.blockId = blockId

        super.init()

        startDownloading()
    }

    func startDownloading() {
        Task { @MainActor in
            guard let url = file.metadata.contentUrl else { return }
            let data = try await fileDownloader.downloadData(url: url)
            let path = file.originalPath(with: blockId)

            try FileManager.default.createDirectory(
                at: path.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            try? data.write(to: path)

            previewItemURL = path
            didUpdateContentSubject.send()
        }
    }
}
