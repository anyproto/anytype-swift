import UIKit

struct ObjectHeaderFilledConfiguration: BlockConfiguration {
    typealias View = ObjectHeaderFilledContentView
    
    let state: ObjectHeaderFilledState
    let isShimmering: Bool
    let width: CGFloat

    var contentInsets: UIEdgeInsets { .zero }
}

