import UIKit

struct ObjectHeaderFilledConfiguration: BlockConfiguration {
    typealias View = ObjectHeaderFilledContentView
    
    let state: ObjectHeaderFilledState
    let isShimmering: Bool
    let sizeConfiguration: HeaderViewSizeConfiguration
}

extension ObjectHeaderFilledConfiguration {
    var contentInsets: UIEdgeInsets { .zero }
}
