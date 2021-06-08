import UIKit
import BlocksModels


struct BlockPageLinkContentConfiguration: UIContentConfiguration, Hashable {
    var information: BlockInformation
    weak var viewModel: BlockPageLinkViewModel?
    
    init?(_ information: BlockInformation) {
        switch information.content {
        case let .link(value) where value.style == .page:
            self.information = information
        default:
            return nil
        }
    }

    func makeContentView() -> UIView & UIContentView {
        let view = BlockPageLinkContentView(configuration: self)
        return view
    }

    func updated(for state: UIConfigurationState) -> BlockPageLinkContentConfiguration {
        return self
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
}
