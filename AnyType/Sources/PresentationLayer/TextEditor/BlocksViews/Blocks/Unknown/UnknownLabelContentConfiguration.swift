import UIKit
import BlocksModels

extension UnknownLabelViewModel {
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.information == rhs.information
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.information)
        }
        
        var information: BlockInformation
        weak var contextMenuHolder: UnknownLabelViewModel?
        
        init(_ information: BlockInformation) {
            /// We could store somewhere which type we could treat as `Unknown`...
//            switch information.content {
//            case .bookmark: break
//            default:
//                let logger = Logging.createLogger(category: .blocksViewsNewUnknownLabel)
//                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
//                break
//            }
            
            self.information = information
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            return view
        }
        
        /// Hm, we could use state as from-user action channel.
        /// for example, if we have value "Checked"
        /// And we pressed something, we should do the following:
        /// We should pass value of state to a configuration.
        /// Next, configuration will send this value to a view model.
        /// Is it what we should use?
        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            /// do something
            return self
        }
    }
}
