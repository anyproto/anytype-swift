import Foundation
import StoredHashMacro

@StoredHash
struct MessageReactionListLayout: Equatable, Hashable {
    let size: CGSize
    let reactionFrames: [CGRect]
    let reactionLayouts: [MessageReactionLayout]
    let addReactionFrame: CGRect?
    
    static let addReactionSize = CGSize(width: 28, height: 28)
}
