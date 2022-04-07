import UIKit

struct RelationBlockContentConfiguration: BlockConfiguration {
    typealias View = RelationBlockView
    
    @EquatableNoop private(set) var actionOnValue: ((_ relation: Relation) -> Void)?
    let relation: Relation

    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
    }
}
