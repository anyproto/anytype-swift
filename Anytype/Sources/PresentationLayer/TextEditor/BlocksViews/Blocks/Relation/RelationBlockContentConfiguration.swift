import UIKit

struct RelationBlockContentConfiguration: BlockConfiguration {
    typealias View = RelationBlockView
    
    @EquatableNoop private(set) var actionOnValue: ((_ relation: Relation) -> Void)?
    let relation: Relation
}
