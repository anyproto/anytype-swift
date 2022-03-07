import UIKit

enum BlocksFileEmptyViewState {
    case `default`
    case uploading
    case error
}

struct BlocksFileEmptyViewConfiguration: BlockConfiguration {
    typealias View = BlocksFileEmptyView

    let image: UIImage
    let text: String
    let state: BlocksFileEmptyViewState
}
