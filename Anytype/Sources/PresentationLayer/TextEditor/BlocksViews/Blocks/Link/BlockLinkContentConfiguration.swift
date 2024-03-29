import Services
import UIKit

struct BlockLinkTextConfiguration: BlockConfiguration {
    typealias View = BlockTextLinkView

    let state: BlockLinkState
    @EquatableNoop private(set) var todoToggleAction: () -> Void

    var contentInsets: UIEdgeInsets { .init(top: 5, left: 20, bottom: 5, right: 20) }
}

struct BlockLinkCardConfiguration: BlockConfiguration {
    typealias View = BlockLinkCardView

    let state: BlockLinkState
    let backgroundColor: UIColor?
    @EquatableNoop private(set) var todoToggleAction: () -> Void

    var hasOwnBackground: Bool { true }
}


extension BlockLinkCardConfiguration {
    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
}
