import UIKit
import AnytypeCore

//struct RelationBlockContentConfiguration: BlockConfiguration {
//    typealias View = RelationBlockView
//    @EquatableNoop private(set) var actionOnValue: ((_ relation: Relation) -> Void)?
//    let relation: Relation
//}

struct RelationBlockContentConfiguration: BlockConfiguration, Hashable {
    var currentConfigurationState: UICellConfigurationState?
    var relation: Relation
    var actionOnValue: ((_ relation: Relation) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        if FeatureFlags.uikitRelationBlock {
            return RelationBlockView(configuration: self)
        }
        return RelationBlockViewDepricated(configuration: self)
    }

    static func == (lhs: RelationBlockContentConfiguration, rhs: RelationBlockContentConfiguration) -> Bool {
        lhs.relation == rhs.relation &&
        lhs.currentConfigurationState == rhs.currentConfigurationState
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(relation)
        hasher.combine(currentConfigurationState)
    }
}
