import Foundation
import Services

enum MessageLinkedObjectsLayout: Equatable, Hashable {
    case list([MessageAttachmentDetails])
    case grid([[MessageAttachmentDetails]])
    case bookmark(ObjectDetails)
}
