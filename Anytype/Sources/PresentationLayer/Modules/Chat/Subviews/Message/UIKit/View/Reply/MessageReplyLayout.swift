import UIKit
import StoredHashMacro

@StoredHash
struct MessageReplyLayout: Equatable, Hashable {
    let size: CGSize
    let lineFrame: CGRect?
    let backgroundFrame: CGRect?
    let authorFrame: CGRect?
    let iconFrame: CGRect?
    let descriptionFrame: CGRect?
}
