import UIKit

struct FilePreviewContext {
    let file: any PreviewRemoteItem

    let sourceView: UIView?
    let previewImage: UIImage?

    let onDidEditFile: (URL) -> Void
}
