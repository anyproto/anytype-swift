import UIKit

struct DepricatedRelationBlockContentConfiguration: BlockConfiguration {
    typealias View = RelationBlockViewDepricated

    @EquatableNoop private(set) var actionOnValue: (() -> Void)?
    let relation: Relation
}

extension DepricatedRelationBlockContentConfiguration {
    var contentInsets: UIEdgeInsets { UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0) }
}
