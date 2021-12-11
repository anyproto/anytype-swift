import UIKit

struct RelationBlockContentConfiguration: BlockConfigurationProtocol, Hashable {
    var currentConfigurationState: UICellConfigurationState?
    var relation: NewRelation
    
    func makeContentView() -> UIView & UIContentView {
        return RelationBlockView(configuration: self)
    }
}
