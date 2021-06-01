import UIKit
import BlocksModels

struct BlockPageLinkContentConfiguration: UIContentConfiguration, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
    
    var information: BlockInformation
    weak var contextMenuHolder: BlockPageLinkViewModel?
    
    init?(_ information: BlockInformation) {
        switch information.content {
        case let .link(value) where value.style == .page:
            self.information = .init(information: information)
        default:
            return nil
        }
    }
    
    /// UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        let view = BlockPageLinkContentView(configuration: self)
        self.contextMenuHolder?.addContextMenuIfNeeded(view)
        return view
    }
    
    /// Hm, we could use state as from-user action channel.
    /// for example, if we have value "Checked"
    /// And we pressed something, we should do the following:
    /// We should pass value of state to a configuration.
    /// Next, configuration will send this value to a view model.
    /// Is it what we should use?
    func updated(for state: UIConfigurationState) -> BlockPageLinkContentConfiguration {
        /// do something
        return self
    }
}
