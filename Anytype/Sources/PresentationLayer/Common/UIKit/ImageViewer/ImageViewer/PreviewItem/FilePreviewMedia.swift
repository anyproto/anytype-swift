import QuickLook
import Combine
import BlocksModels

final class FilePreviewMedia: NSObject, PreviewRemoteItem {
    // MARK: - PreviewRemoteItem
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    let file: BlockFile

    // MARK: - QLPreviewItem
    var previewItemTitle: String? { "" }
    var previewItemURL: URL?

    private let fileDownloader = FileDownloader()

    init(file: BlockFile) {
        self.file = file

        super.init()

        startDownloading()
    }

    func startDownloading() {
        Task { @MainActor in
            guard let url = file.metadata.contentUrl else { return }
            let data = try await fileDownloader.downloadData(url: url)

            try? data.write(to: file.originalPath)
            previewItemURL = file.originalPath
            didUpdateContentSubject.send()
        }
    }
}
