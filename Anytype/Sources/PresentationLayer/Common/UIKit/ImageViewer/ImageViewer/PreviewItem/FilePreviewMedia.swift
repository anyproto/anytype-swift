import QuickLook
import Combine
import Services
import AnytypeCore

final class FilePreviewMedia: NSObject, PreviewRemoteItem, @unchecked Sendable {
    
    // MARK: - PreviewRemoteItem
    let id: String
    let fileDetails: FileDetails
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()

    // MARK: - QLPreviewItem
    var previewItemTitle: String? { fileDetails.fileName }
    var previewItemURL: URL?

    private let fileDownloader = FileDownloader()

    init(fileDetails: FileDetails) {
        self.id = fileDetails.id
        self.fileDetails = fileDetails
        
        super.init()
        
        let path = FileManager.originalPath(objectId: fileDetails.id, fileName: fileDetails.fileName)
        if FileManager.default.fileExists(atPath: path.relativePath) {
            self.previewItemURL = path
        } else {
            startDownloading()
        }
    }

    func startDownloading() {
        Task {
            do {
                guard let url = ContentUrlBuilder.fileUrl(fileId: fileDetails.id) else { return }
                let data = try await fileDownloader.downloadData(url: url)
                let path = FileManager.originalPath(objectId: fileDetails.id, fileName: fileDetails.fileName)

                try FileManager.default.createDirectory(
                    at: path.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                try data.write(to: path, options: [.atomic])
                previewItemURL = path
                didUpdateContentSubject.send()
            } catch {
                anytypeAssertionFailure("Failed to write file into temporary directory")
            }
        }
    }
}
