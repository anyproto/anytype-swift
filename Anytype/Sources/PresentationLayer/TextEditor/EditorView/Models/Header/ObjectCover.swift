import UIKit.UIColor

struct ObjectCover: Hashable {
    let state: ObjectCoverState
    let onTap: () -> ()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
    
    static func == (lhs: ObjectCover, rhs: ObjectCover) -> Bool {
        lhs.state == rhs.state
    }
}

enum ObjectCoverState: Hashable {
    case cover(DocumentCover)
    case preview(UIImage)
}
