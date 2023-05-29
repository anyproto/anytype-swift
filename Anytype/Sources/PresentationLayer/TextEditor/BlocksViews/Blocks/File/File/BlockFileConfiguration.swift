import BlocksModels
import UIKit

struct BlockFileConfiguration: BlockConfiguration {
    typealias View = BlockFileView

    let data: BlockFileMediaData

    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 1, left: 20, bottom: 1, right: 20)
    }
}
