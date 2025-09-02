import Foundation

struct MessageReactionListLayout: Equatable {
    let size: CGSize
    let reactionFrames: [CGRect]
    let reactionLayouts: [MessageReactionLayout]
    let addReactionFrame: CGRect?
    
    static let addReactionSize = CGSize(width: 28, height: 28)
}
