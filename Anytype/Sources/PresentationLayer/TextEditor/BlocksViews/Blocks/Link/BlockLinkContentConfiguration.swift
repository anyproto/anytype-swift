import BlocksModels
import UIKit

struct BlockLinkContentConfiguration: BlockConfiguration {
    typealias View = BlockLinkView

    let state: BlockLinkState
    let backgroundColor: UIColor
}

extension BlockLinkContentConfiguration {
    var contentInsets: UIEdgeInsets {
        guard !state.deleted else {
            return UIEdgeInsets(top: 5, left: 20, bottom: -5, right: -20)
        }

        switch state.cardStyle {
        case .text, .inline:
            return UIEdgeInsets(top: 5, left: 20, bottom: -5, right: -20)
        case .card:
            return UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
        }
    }
}
