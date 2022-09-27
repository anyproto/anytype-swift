import UIKit

struct FilePreviewContext {
    let file: PreviewRemoteItem

    let sourceView: UIView?
    let previewImage: UIImage?

    let onDidEditFile: (URL) -> Void
}
