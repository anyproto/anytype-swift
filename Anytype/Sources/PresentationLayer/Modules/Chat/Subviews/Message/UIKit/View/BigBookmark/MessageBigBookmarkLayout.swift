import Foundation
import StoredHashMacro

@StoredHash
struct MessageBigBookmarkLayout: Equatable, Hashable {
    let size: CGSize
    let imageFrame: CGRect?
    let hostFrame: CGRect?
    let titleFrame: CGRect?
    let descriptionFrame: CGRect?
}
