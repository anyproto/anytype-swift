import Services
import Combine
import QuickLook

enum PreviewRemoteItemType {
    case image(_ previewImage: UIImage? = nil)
    case file
}

final class PreviewRemoteItem: NSObject, QLPreviewItem, Identifiable, PreviewMediaHandlingOutput, @unchecked Sendable {
    let id: String
    let fileDetails: FileDetails
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    
    private let type: PreviewRemoteItemType
    private var handler: any PreviewMediaHandlingProtocol
    
    // MARK: - QLPreviewItem
    var previewItemTitle: String? { fileDetails.fileName }
    var previewItemURL: URL?
    
    init(fileDetails: FileDetails, type: PreviewRemoteItemType) {
        self.id = fileDetails.id
        self.fileDetails = fileDetails
        self.type = type
        
        switch type {
        case .image(let previewImage):
            handler = ImagePreviewMediaHandler(fileDetails: fileDetails, previewImage: previewImage)
        case .file:
            handler = FilePreviewMediaHandler(fileDetails: fileDetails)
        }
        super.init()
        handler.output = self
        
        let path = FileManager.originalPath(objectId: fileDetails.id, fileName: fileDetails.fileName)
        if FileManager.default.fileExists(atPath: path.relativePath) {
            self.previewItemURL = path
        } else {
            startDownloading()
        }
    }
    
    private func startDownloading() {
        handler.startDownloading()
    }
    
    // MARK: - PreviewMediaHandlingOutput
    
    func onUpdate(path: URL) {
        previewItemURL = path
        didUpdateContentSubject.send(())
    }
}
