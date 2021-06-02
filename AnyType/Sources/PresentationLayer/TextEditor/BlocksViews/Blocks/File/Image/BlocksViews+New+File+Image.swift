import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.File.Image


extension Namespace {
    final class ViewModel: BlocksViews.File.Base.ViewModel {
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
        }
        
        override func handleReplace() {
            let model: MediaPicker.ViewModel = .init(type: .images)
            self.configureMediaPickerViewModel(model)
            self.send(userAction: .specific(.file(.shouldShowImagePicker(.init(model: model)))))
        }
    }
}

// MARK: - UIView
private extension Namespace {
    class UIKitView: UIView {
        
        typealias File = BlocksViews.File.Image.ViewModel.File
        typealias State = File.State
        typealias EmptyView = BlocksViews.File.Base.TopUIKitEmptyView
        
        struct Layout {
            let imageContentViewDefaultHeight: CGFloat = 250
            var imageViewTop: CGFloat = 4
            let emptyViewHeight: CGFloat = 52
            let emptyViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
        }
        
        struct Resource {
            var emptyViewPlaceholderTitle = "Add link or Upload a picture"
            var emptyViewImagePath = "TextEditor/Style/File/Empty/Image"
        }
        
        var subscription: AnyCancellable?
        
        var setupImageSubscription: AnyCancellable?
        
        var resource: Resource = .init()
        var layout: Layout = .init()
        
        // MARK: Views
        var imageContentView: UIView!
        var imageContentViewHeight: NSLayoutConstraint?
        var imageView: UIImageView!
        
        var emptyView: EmptyView!
        
        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            // Default behavior
            self.setupEmptyView()
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        func setupImageView() {
            self.imageContentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.imageView = {
                let view = UIImageView()
                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.imageContentView.addSubview(self.imageView)
            self.addSubview(imageContentView)
        }
        
        func setupEmptyView() {
            
            self.emptyView = {
                let view = EmptyView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.emptyView.configured(.init(placeholderText: self.resource.emptyViewPlaceholderTitle, imagePath: self.resource.emptyViewImagePath))
            
            self.addSubview(emptyView)
        }
        
        // MARK: Layout
        func addLayout() {
            addEmptyViewLayout()
        }
        
        func addImageViewLayout() {
            if let view = self.imageContentView, let superview = view.superview {
                imageContentViewHeight = view.heightAnchor.constraint(equalToConstant: self.layout.imageContentViewDefaultHeight)
                // We need priotity here cause cell self size constraint will conflict with ours
                imageContentViewHeight?.priority = .init(750)
                imageContentViewHeight?.isActive = true
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.imageView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.imageViewTop),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        func addEmptyViewLayout() {
            if let view = self.emptyView, let superview = view.superview {
                let heightAnchor = view.heightAnchor.constraint(equalToConstant: self.layout.emptyViewHeight)
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                // We need priotity here cause cell self size constraint will conflict with ours
                bottomAnchor.priority = .init(750)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    bottomAnchor,
                    heightAnchor
                ])
            }
        }
        
        private func removeViewsIfExist() {
            if !imageContentView.isNil {
                self.imageContentView.removeFromSuperview()
            }
            if !emptyView.isNil {
                self.emptyView.removeFromSuperview()
            }
        }
        
        func setupImage(_ file: BlockContent.File) {
            guard !file.metadata.hash.isEmpty else { return }
            let imageId = file.metadata.hash
            
            self.setupImageSubscription = URLResolver.init().obtainImageURLPublisher(imageId: imageId).safelyUnwrapOptionals().ignoreFailure().flatMap({
                ImageLoaderObject($0).imagePublisher
            }).receiveOnMain().sink { [weak self] (value) in
                if let imageView = self?.imageView {
                    imageView.image = value
                    self?.updateImageConstraints()
                }
            }
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
        
        private func handleFile(_ file: BlockContent.File) {
            self.removeViewsIfExist()
            
            switch file.state  {
            case .empty:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.change(state: .empty)
            case .uploading:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.change(state: .uploading)
            case .done:
                self.setupImageView()
                self.addImageViewLayout()
                self.setupImage(file)
            case .error:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.change(state: .error)
            }
        }
        
        func configured(publisher: AnyPublisher<File, Never>) -> Self {
            self.subscription = publisher.receiveOnMain().sink { [weak self] (value) in
                self?.handleFile(value)
            }
            return self
        }
    }
}

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
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
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
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
            
            self.information = .init(information: information)
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            self.contextMenuHolder?.addContextMenuIfNeeded(view)
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
private extension Namespace.ViewModel {
    final class ContentView: UIView & UIContentView {
        
        private var imageContentViewHeight: NSLayoutConstraint?
        private let imageView = UIImageView()
        private let emptyView: Namespace.UIKitView.EmptyView = .init()
        private var onLayoutSubviewsSubscription: AnyCancellable?
        private var imageLoader = ImageLoader()
        
        private var resource = Namespace.UIKitView.Resource()
        private var layout: Namespace.UIKitView.Layout = {
            var layout: Namespace.UIKitView.Layout = .init()
            layout.imageViewTop = 0
            return layout
        }()
        
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
            
            /// Empty View
            self.emptyView.configured(.init(placeholderText: self.resource.emptyViewPlaceholderTitle, imagePath: self.resource.emptyViewImagePath))
            
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
            imageContentViewHeight = imageView.heightAnchor.constraint(equalToConstant: self.layout.imageContentViewDefaultHeight)
            // We need priotity here cause cell self size constraint will conflict with ours
            //                imageContentViewHeight?.priority = .init(750)
            imageContentViewHeight?.isActive = true
            imageView.pinAllEdges(to: self, insets: layout.imageViewInsets)
        }
        
        func addEmptyViewLayout() {
            let view = self.emptyView
            if let superview = view.superview {
                let heightAnchor = view.heightAnchor.constraint(equalToConstant: self.layout.emptyViewHeight)
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                // We need priotity here cause cell self size constraint will conflict with ours
                bottomAnchor.priority = .init(750)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor,
                                                  constant: layout.emptyViewInsets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor,
                                                   constant: -layout.emptyViewInsets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    bottomAnchor,
                    heightAnchor
                ])
            }
        }
        
        func setupImage(_ file: File, _ oldFile: File?) {
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
        private func handleFile(_ file: File, _ oldFile: File?) {
//            self.removeViewsIfExist()
            
            switch file.state {
            case .empty:
                self.imageView.removeFromSuperview()
                self.addSubview(self.emptyView)
                self.addEmptyViewLayout()
                self.emptyView.change(state: .empty)
            case .uploading:
                self.imageView.removeFromSuperview()
                self.addSubview(self.emptyView)
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
            currentConfiguration?.contextMenuHolder?.addContextMenuIfNeeded(self)
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
