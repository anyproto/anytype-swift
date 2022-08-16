import UIKit

struct ObjectHeaderEmptyConfiguration: BlockConfiguration {
    typealias View = ObjectHeaderEmptyContentView
    
    let data: ObjectHeaderEmptyData
    let isShimmering: Bool

    var contentInsets: UIEdgeInsets { .zero }
}
