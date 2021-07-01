import UIKit
import BlocksModels

struct BlockImageConfiguration: UIContentConfiguration, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
    
    var information: BlockInformation

    init(_ information: BlockInformation) {
        /// We should warn if we have incorrect content type (?)
        /// Don't know :(
        /// Think about failable initializer
        
        switch information.content {
        case let .file(value) where value.contentType == .image: break
        default:
            assertionFailure("Can't create content configuration for content:\(information.content)")
            break
        }
        
        self.information = information
    }
            
    /// UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        let view = BlockImageContentView(configuration: self)
        return view
    }
    
    /// Hm, we could use state as from-user action channel.
    /// for example, if we have value "Checked"
    /// And we pressed something, we should do the following:
    /// We should pass value of state to a configuration.
    /// Next, configuration will send this value to a view model.
    /// Is it what we should use?
    func updated(for state: UIConfigurationState) -> BlockImageConfiguration {
        /// do something
        return self
    }
}
