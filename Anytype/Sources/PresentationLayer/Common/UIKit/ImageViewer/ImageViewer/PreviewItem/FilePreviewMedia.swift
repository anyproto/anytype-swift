import QuickLook
import Combine
import Services

final class FilePreviewMedia: NSObject, PreviewRemoteItem {
    // MARK: - PreviewRemoteItem
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    let file: BlockFile
    let blockId: String
    let fileDetails: FileDetails

    // MARK: - QLPreviewItem
    var previewItemTitle: String? { "" }
    var previewItemURL: URL?

    private let fileDownloader = FileDownloader()

    init(file: BlockFile, blockId: String, fileDetails: FileDetails) {
        self.file = file
        self.blockId = blockId
        self.fileDetails = fileDetails

        super.init()

        startDownloading()
    }

    func startDownloading() {
        Task { @MainActor in
            guard let url = file.contentUrl else { return }
            let data = try await fileDownloader.downloadData(url: url)
            let path = file.originalPath(blockId: blockId, fileName: fileDetails.fileName)

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
