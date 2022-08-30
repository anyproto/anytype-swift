import UIKit

enum BlocksFileEmptyViewState {
    case `default`
    case uploading
    case error
}

struct BlocksFileEmptyViewConfiguration: BlockConfiguration {
    typealias View = BlocksFileEmptyView

    let imageAsset: ImageAsset
    let text: String
    let state: BlocksFileEmptyViewState
}

extension BlocksFileEmptyViewConfiguration {
    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 7, left: 20, bottom: -7, right: -20)
    }
}
