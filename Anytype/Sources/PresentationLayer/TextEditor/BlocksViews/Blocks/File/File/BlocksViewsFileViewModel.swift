import UIKit
import BlocksModels

final class BlocksViewsFileViewModel: BlocksViewsBaseFileViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        let configuration = ContentConfiguration.init(block.blockModel.information)
        return configuration
    }
    
    override func handleReplace() {
        let model: CommonViews.Pickers.File.Picker.ViewModel = .init()
        configureListening(model)
        router?.showFilePicker(model: model)
    }
}

// MARK: ContentConfiguration
extension BlocksViewsFileViewModel {
    
    /// As soon as we have builder in this type ( makeContentView )
    /// We could map all states ( for example, image has several states ) to several different ContentViews.
    ///
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.information == rhs.information
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.information)
        }
        
        let information: BlockInformation

        init(_ information: BlockInformation) {
            /// We should warn if we have incorrect content type (?)
            /// Don't know :(
            /// Think about failable initializer
            
            switch information.content {
            case let .file(value) where value.contentType == .file: break
            default:
                assertionFailure("Can't create content configuration for content: \(information.content)")
                break
            }
            
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

private extension BlocksViewsFileViewModel {
    final class ContentView: UIView & UIContentView {
        
        private enum Constants {
            static let topViewContentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
        }
        
        private let topView = BlocksViewsFileUIKitView()
        
        private var currentConfiguration: ContentConfiguration
        
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                guard let configuration = newValue as? ContentConfiguration else { return }
                guard self.currentConfiguration != configuration else { return }
                applyNewConfiguration()
            }
        }
        
        init(configuration: ContentConfiguration) {
            self.currentConfiguration = configuration
            super.init(frame: .zero)
            setup()
            applyNewConfiguration()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        private func setup() {
            topView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(topView)
            topView.pinAllEdges(to: self, insets: Constants.topViewContentInsets)
        }
        
        private func handle(_ value: BlockFile) {
            switch value.contentType {
            case .file: self.topView.apply(value)
            default: return
            }
        }
        
        private func applyNewConfiguration() {
            switch self.currentConfiguration.information.content {
            case let .file(value):
                handle(value)
            default:
                return
            }
        }
    }
}
