import Foundation
import StoredHashMacro

@StoredHash
struct MessageGridAttachmentsContainerLayout: Equatable, Hashable {
    let size: CGSize
    let objectFrames: [CGRect]
}
