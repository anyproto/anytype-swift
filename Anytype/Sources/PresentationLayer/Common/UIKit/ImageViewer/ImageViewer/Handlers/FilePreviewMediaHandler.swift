import Services
import UIKit
import Combine
import AnytypeCore

final class FilePreviewMediaHandler: PreviewMediaHandlingProtocol, @unchecked Sendable {
    
    private let fileDetails: FileDetails
    private let fileDownloader = FileDownloader()
    
    weak var output: (any PreviewMediaHandlingOutput)? = nil
    
    init(fileDetails: FileDetails) {
        self.fileDetails = fileDetails
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
                output?.onUpdate(path: path)
            } catch {
                anytypeAssertionFailure("Failed to write file into temporary directory")
            }
        }
    }
}
