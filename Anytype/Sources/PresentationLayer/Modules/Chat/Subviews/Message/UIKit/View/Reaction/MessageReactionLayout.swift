import Foundation

struct MessageReactionLayout: Equatable {
    let size: CGSize
    let emojiFrame: CGRect
    let countFrame: CGRect?
    let iconFrme: CGRect?
    
    static let height: CGFloat = 28
    static let iconSize = CGSize(width: 20, height: 20)
}
