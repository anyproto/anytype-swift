import Services
import UIKit

struct BlockBookmarkConfiguration: BlockConfiguration {
    typealias View = BlockBookmarkView

    let payload: BlockBookmarkPayload
    let backgroundColor: UIColor?
}

extension BlockBookmarkConfiguration {
    var hasOwnBackground: Bool { true }
}
