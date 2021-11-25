import UIKit

struct RelationBlockContentConfiguration<ViewModel: RelationBlockViewModelProtocol>: BlockConfigurationProtocol, Hashable {
    var currentConfigurationState: UICellConfigurationState?
    var viewModel: ViewModel
    
    func makeContentView() -> UIView & UIContentView {
        return RelationBlockView<ViewModel>(configuration: self)
    }

    static func == (lhs: RelationBlockContentConfiguration, rhs: RelationBlockContentConfiguration) -> Bool {
        lhs.viewModel.relation == rhs.viewModel.relation &&
        lhs.currentConfigurationState == rhs.currentConfigurationState
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.relation)
        hasher.combine(currentConfigurationState)
    }

}
