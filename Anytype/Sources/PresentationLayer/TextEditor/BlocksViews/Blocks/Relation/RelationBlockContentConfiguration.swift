import UIKit

struct RelationBlockContentConfiguration: BlockConfigurationProtocol, Hashable {
    var currentConfigurationState: UICellConfigurationState?
    var relation: Relation
    
    func makeContentView() -> UIView & UIContentView {
        return RelationBlockView(configuration: self)
    }
}
