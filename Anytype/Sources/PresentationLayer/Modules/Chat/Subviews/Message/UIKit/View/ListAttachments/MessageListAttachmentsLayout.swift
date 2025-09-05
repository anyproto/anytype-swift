import Foundation
import StoredHashMacro

@StoredHash
struct MessageListAttachmentsLayout: Equatable, Hashable {
    let size: CGSize
    let objectFrames: [CGRect]
}
