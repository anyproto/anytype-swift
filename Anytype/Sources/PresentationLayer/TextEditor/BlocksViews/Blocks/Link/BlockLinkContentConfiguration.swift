import BlocksModels
import UIKit

struct BlockLinkContentConfiguration: BlockConfiguration {
    typealias View = BlockLinkView

    let state: BlockLinkState
}

extension BlockLinkContentConfiguration {
    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 20, bottom: -5, right: -20)
    }
}
