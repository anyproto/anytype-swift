import UIKit
import BlocksModels
import Combine

final class BlocksViewsImageViewModel: BlocksViewsBaseFileViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        let configuration = ContentConfiguration.init(block.blockModel.information)
        return configuration
    }
    
    override func handleReplace() {
        let model: MediaPicker.ViewModel = .init(type: .images)
        configureMediaPickerViewModel(model)
        router?.showImagePicker(model: model)
    }
}

// MARK: ContentConfiguration
extension BlocksViewsImageViewModel {
    
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

// MARK: - ContentView
private extension BlocksViewsImageViewModel {
    final class ContentView: UIView & UIContentView {
        
        private var imageContentViewHeight: NSLayoutConstraint?
        private let imageView = UIImageView()
        private let emptyView = BlocksViewsBaseFileTopUIKitEmptyView(
            viewData: .init(
                image: UIImage.blockFile.empty.image,
                placeholderText: BlocksViewsImageUIKitView.Constants.emptyViewPlaceholderTitle
            )
        )
        private var onLayoutSubviewsSubscription: AnyCancellable?
        private var imageLoader = ImageLoader()
        
        private var currentConfiguration: ContentConfiguration!
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                guard let configuration = newValue as? ContentConfiguration,
                      currentConfiguration != configuration else { return }
                self.apply(configuration: configuration)
            }
        }

        init(configuration: ContentConfiguration) {
            super.init(frame: .zero)
            self.setup()
            self.apply(configuration: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        /// Setup
        func setup() {
            self.setupUIElements()
            self.imageLoader.configured(self.imageView)
        }
        
        func setupUIElements() {
            /// Image View
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.clipsToBounds = true
            self.imageView.isUserInteractionEnabled = true
            
            /// Disable Autoresizing Mask
            [self.emptyView, self.imageView].forEach { (value) in
                value.translatesAutoresizingMaskIntoConstraints = false
            }

            /// View hierarchy
            self.addSubview(self.emptyView)
            addSubview(imageView)
        }
        
        func addImageViewLayout() {
            imageContentViewHeight = imageView.heightAnchor.constraint(equalToConstant: BlocksViewsImageUIKitView.Layout.imageContentViewDefaultHeight)
            // We need priotity here cause cell self size constraint will conflict with ours
            //                imageContentViewHeight?.priority = .init(750)
            imageContentViewHeight?.isActive = true
            imageView.pinAllEdges(to: self, insets: BlocksViewsImageUIKitView.Layout.imageViewInsets)
        }
        
        func addEmptyViewLayout() {
            let view = self.emptyView
            if let superview = view.superview {
                let heightAnchor = view.heightAnchor.constraint(equalToConstant: BlocksViewsImageUIKitView.Layout.emptyViewHeight)
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                // We need priotity here cause cell self size constraint will conflict with ours
                bottomAnchor.priority = .init(750)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(
                        equalTo: superview.leadingAnchor,
                        constant: BlocksViewsImageUIKitView.Layout.emptyViewInsets.left
                    ),
                    view.trailingAnchor.constraint(
                        equalTo: superview.trailingAnchor,
                        constant: -BlocksViewsImageUIKitView.Layout.emptyViewInsets.right
                    ),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    bottomAnchor,
                    heightAnchor
                ])
            }
        }
        
        func setupImage(_ file: BlockFile, _ oldFile: BlockFile?) {
            guard !file.metadata.hash.isEmpty else { return }
            let imageId = file.metadata.hash
            guard imageId != oldFile?.metadata.hash else { return }
            // We could put image into viewModel.
            // In this case we would only check
            self.imageLoader.update(imageId: imageId)
        }
        
        // TODO: Will work dynamic when finish granual reload of parent tableView
        private func updateImageConstraints()  {
            if let image = self.imageView.image, image.size.width > 0 {
                let width = image.size.width
                let height = image.size.height
                let viewWidth = self.imageView.frame.width
                let ratio = viewWidth / width
                let scaledHeight = height * ratio
                
                self.imageContentViewHeight?.constant = scaledHeight
            }
        }
        
        /// Cleanup
        private func cleanupOnNewConfiguration() {
            self.imageLoader.cleanupSubscription()
        }
        /// Handle new value
        private func handleFile(_ file: BlockFile, _ oldFile: BlockFile?) {

            switch file.state {
            case .empty:
                self.imageView.removeFromSuperview()
                self.addSubview(emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .empty)
            case .uploading:
                self.imageView.removeFromSuperview()
                self.addSubview(emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .uploading)
            case .done:
                self.emptyView.removeFromSuperview()
                self.addSubview(self.imageView)
                self.addImageViewLayout()
                self.setupImage(file, oldFile)
            case .error:
                self.imageView.removeFromSuperview()
                self.addSubview(self.emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .error)
            }
            switch file.state {
            case .empty, .error, .uploading:
                self.emptyView.isHidden = false
                self.imageView.isHidden = true
            case .done:
                self.emptyView.isHidden = true
                self.imageView.isHidden = false
            }
            self.invalidateIntrinsicContentSize()
        }
        
        private func apply(configuration: ContentConfiguration) {
            guard self.currentConfiguration != configuration else { return }
            let oldConfiguration = self.currentConfiguration
            self.currentConfiguration = configuration
            
            self.cleanupOnNewConfiguration()
            switch (self.currentConfiguration.information.content, oldConfiguration?.information.content) {
            case let (.file(value), .file(oldValue)): self.handleFile(value, oldValue)
            case let (.file(value), .none): self.handleFile(value, .none)
            default: return
            }
        }
        
        /// MARK: - EditorModuleDocumentViewCellContentConfigurationsCellsListenerProtocol
        private func refreshImage() {
            switch self.currentConfiguration.information.content {
            case let .file(value): self.handleFile(value, .none)
            default: return
            }
        }
    }
}
