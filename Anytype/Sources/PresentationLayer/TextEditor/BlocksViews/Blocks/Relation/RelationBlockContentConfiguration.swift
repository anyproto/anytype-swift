import UIKit

struct RelationBlockContentConfiguration: BlockConfiguration {
    typealias View = RelationBlockView
    
    @EquatableNoop private(set) var actionOnValue: (() -> Void)?
    let property: PropertyItemModel

    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
