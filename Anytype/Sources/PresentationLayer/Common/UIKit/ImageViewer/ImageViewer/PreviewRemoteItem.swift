import BlocksModels
import Combine
import QuickLook

protocol PreviewRemoteItem: QLPreviewItem {
    var file: BlockFile { get }
    var didUpdateContentSubject: PassthroughSubject<Void, Never> { get }
}
