import UIKit

struct RelationBlockContentConfiguration: BlockConfigurationProtocol, Hashable {
    var currentConfigurationState: UICellConfigurationState?
    var relation: Relation
    var actionOnValue: ((_ relation: Relation) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        return RelationBlockView(configuration: self)
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
