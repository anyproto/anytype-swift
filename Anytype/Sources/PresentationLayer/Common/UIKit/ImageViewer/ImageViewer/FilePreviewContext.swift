import UIKit

struct FilePreviewContext {
    let previewItem: any PreviewRemoteItem

    let sourceView: UIView?
    let previewImage: UIImage?

    let onDidEditFile: (URL) -> Void
}
