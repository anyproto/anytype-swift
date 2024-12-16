import Foundation

enum MessageLinkedObjectsLayout: Equatable, Hashable {
    case list([MessageAttachmentDetails])
    case grid([[MessageAttachmentDetails]])
}
