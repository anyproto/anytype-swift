import Services
import Combine
import QuickLook

protocol PreviewRemoteItem: QLPreviewItem, Identifiable {
    var id: String { get }
    var fileDetails: FileDetails { get }
    var didUpdateContentSubject: PassthroughSubject<Void, Never> { get }
}
