import UIKit

struct FilePreviewContext {
    let previewItem: PreviewRemoteItem

    let sourceView: UIView?
    let previewImage: UIImage?

    let onDidEditFile: (URL) -> Void
}
