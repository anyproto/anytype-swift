import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices

// TODO: Rethink.
// Maybe we should use SwiftUI which will be embedded in UIKit.
// In this case we will receive simple updates of all views.

// MARK: ViewModel
class BookmarkViewModel: BaseBlockViewModel {
    private var service: BlockActionsServiceBookmark = .init()
    
    private var subscription: AnyCancellable?
    private var toolbarSubscription: AnyCancellable?
    @Published private var resourcePublished: Resource?
    var imagesPublished: Resource.ImageLoader = .init()
    private var publisher: AnyPublisher<BlockContent.Bookmark, Never> = .empty()
            
    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = ContentConfiguration.init(block.blockModel.information)
        configuration.contextMenuHolder = self
        return configuration
    }
    
    // MARK: Subclassing
    override init(_ block: BlockActiveRecordModelProtocol, delegate: BaseBlockDelegate?) {
        super.init(block, delegate: delegate)
        self.setup()
    }
    
    // MARK: Subclassing / Events
    override func didSelectRowInTableView() {
        // we should show image picker only for empty state
        // TODO: Need to think about error state, reload or something
        
        // Think what we should check...
        // Empty URL?
        if case let .bookmark(value) = block.content, !value.url.isEmpty {
            assertionFailure("User pressed on BookmarkBlocksViews when our state is not empty. Our URL is not empty")
            return
        }
                        
        send(userAction: .bookmark(toolbarActionSubject))
    }
    
    override func handle(toolbarAction: BlockToolbarAction) {
        switch toolbarAction {
        case let .bookmark(.fetch(value)):
            self.update { (block) in
                switch block.content {
                case let .bookmark(bookmark):
                    var bookmark = bookmark
                    bookmark.url = value.absoluteString
                    
                    var blockModel = block.blockModel
                    blockModel.information.content = .bookmark(bookmark)
                default: return
                }
            }
        default: return
        }
    }
    
    override var diffable: AnyHashable {
        let diffable = super.diffable
        if case let .bookmark(value) = block.content {
            let newDiffable: [String: AnyHashable] = [
                "parent": diffable,
                "bookmark": ["url": value.url, "title": value.title]
            ]
            return .init(newDiffable)
        }
        return diffable
    }

    private func setup() {
        self.setupSubscribers()
    }
    
    func setupSubscribers() {
//            self.toolbarSubscription = self.toolbarActionSubject.sink { [weak self] (value) in
//                self?.handle(toolbarAction: value)
//            }
        self.publisher = block.didChangeInformationPublisher().map({ value -> BlockContent.Bookmark? in
            switch value.content {
            case let .bookmark(value): return value
            default: return nil
            }
        }).safelyUnwrapOptionals().eraseToAnyPublisher()
        
        /// Also embed image data to state.
        self.subscription = self.publisher.sink(receiveValue: { [weak self] (value) in
            let resource = ResourceConverter.asOurModel(value)
            self?.resourcePublished = resource
            self?.setupImages(resource)
        })
    }
    
    // MARK: Images
    func setupImages(_ resource: Resource?) {
        switch resource?.state {
        case let .fetched(payload):
            switch (payload.hasImage(), payload.hasIcon()) {
            case (false, false): self.imagesPublished.resetImages()
            default:
                if payload.hasImage() {
                    self.imagesPublished.subscribeImage(payload.image)
                }
                if payload.hasIcon() {
                    /// create publisher that uploads image
                    self.imagesPublished.subscribeIcon(payload.icon)
                }
            }
        default: return
        }
    }
            
    // MARK: Contextual Menu
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate)),
        ])
    }
}
// MARK: - State Converter
extension BookmarkViewModel {
    
    enum ResourceConverter {
        static func asModel(_ value: Resource) -> BlockContent.Bookmark? {
            return nil
        }
        
        static func asOurModel(_ value: BlockContent.Bookmark) -> Resource? {
            if value.url.isEmpty {
                return .empty()
            }
            
            if value.title.isEmpty {
                return .onlyURL(.init(url: value.url, title: value.title, subtitle: value.theDescription, image: .init(hash: value.imageHash, url: nil, data: nil), icon: .init(hash: value.faviconHash, url: nil, data: nil)))
            }
            
            return .fetched(.init(url: value.url, title: value.title, subtitle: value.theDescription, image: .init(hash: value.imageHash, url: nil, data: nil), icon: .init(hash: value.faviconHash, url: nil, data: nil)))
        }
    }
}

// MARK: - Resource
extension BookmarkViewModel {
    
    class Resource {
        
        class ImageLoader {
            /// I want to subscribe on current value subject, lol.
            var imageProperty: ImageProperty?
            var iconProperty: ImageProperty?
            func resetImages() {
//                self.imageProperty = nil
//                self.iconProperty = nil
            }
            func subscribeImage(_ payload: Payload.Image?) {
                guard let image = payload else { return }
                if let hash = image.hash {
                    self.imageProperty = .init(imageId: hash, .init(width: .default))
                }
            }
            func subscribeIcon(_ payload: Payload.Image?) {
                guard let image = payload else { return }
                if let hash = image.hash {
                    self.iconProperty = .init(imageId: hash, .init(width: .thumbnail))
                }
            }
        }
        
        struct Payload {
            struct Image {
                var hash: String?
                var url: URL?
                var data: Data?
            }
            var url: String?
            var title: String?
            var subtitle: String?
            var image: Image?
            var icon: Image?
            
            func hasImage() -> Bool { !self.image.isNil }
            func hasIcon() -> Bool { !self.icon.isNil }
        }
        enum State {
            case empty
            case onlyURL(Payload)
            case fetched(Payload)
        }
        
        required init(state: State) { self.state = state }
        
        var state: State
        var imageLoader: ImageLoader?
        
        func update(_ imageLoader: ImageLoader?) {
            self.imageLoader = imageLoader
        }
                
        /// We could store images here, for example.
        /// Or we could update images directly.
        /// Or we could store images properties as @Published here.
        static func empty() -> Self { .init(state: .empty) }
        static func onlyURL(_ payload: Payload) -> Self { .init(state: .onlyURL(payload)) }
        static func fetched(_ payload: Payload) -> Self { .init(state: .fetched(payload)) }
    }
}

// MARK: - UIView / WithBookmark / Style
private extension BlocksViews.Bookmark.UIKitViewWithBookmark {
    enum Style {
        case presentation
        var titleFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15, weight: .semibold)
            }
        }
        var subtitleFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15)
            }
        }
        var urlFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15, weight: .light)
            }
        }
                
        var titleColor: UIColor {
            switch self {
            case .presentation: return .grayscale90
            }
        }
        var subtitleColor: UIColor {
            switch self {
            case .presentation: return .gray
            }
        }
        var urlColor: UIColor {
            switch self {
            case .presentation: return .grayscale90
            }
        }
    }
}

// MARK: - UIView / WithBookmark / Layout
private extension BlocksViews.Bookmark.UIKitViewWithBookmark {
    struct Layout {
        var commonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        var spacing: CGFloat = 5
        var imageSizeFactor: CGFloat = 1 / 3
        var imageHeightConstant: CGFloat = 150
        var iconHeight: CGFloat = 24
    }
}

// MARK: - UIKitViewWithBookmark
private extension BlocksViews.Bookmark {
    class UIKitViewWithBookmark: UIView {
        /// Variables
        var style: Style = .presentation
        
        var layout: Layout = .init()
        
        /// Publishers
        private var subscription: AnyCancellable?
        private var resourceStream: AnyPublisher<BookmarkViewModel.Resource?, Never> = .empty()
        @Published var resource: BookmarkViewModel.Resource? {
            didSet {
                self.handle(self.resource)
            }
        }
        
        /// Views
        private var contentView: UIView!
        private var titleView: UILabel!
        private var descriptionView: UILabel!
        private var iconView: UIImageView!
        private var urlView: UILabel!
        
        private var leftStackView: UIStackView!
        private var urlStackView: UIStackView!
        
        private var imageView: UIImageView!
        
        private var imageViewWidthConstraint: NSLayoutConstraint?
        private var imageViewHeightConstraint: NSLayoutConstraint?
        
        /// Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        /// Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }

        /// UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.leftStackView = {
                let view = UIStackView()
                view.axis = .vertical
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.urlStackView = {
                let view = UIStackView()
                view.axis = .horizontal
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.titleView = {
                let view = UILabel()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.font = self.style.titleFont
                view.textColor = self.style.titleColor
                return view
            }()
            
            self.descriptionView = {
                let view = UILabel()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.numberOfLines = 3
                view.lineBreakMode = .byWordWrapping
                view.font = self.style.subtitleFont
                view.textColor = self.style.subtitleColor
                return view
            }()
            
            self.iconView = {
                let view = UIImageView()
                view.contentMode = .scaleAspectFit
                view.clipsToBounds = true
                view.heightAnchor.constraint(equalToConstant: self.layout.iconHeight).isActive = true
                view.widthAnchor.constraint(equalToConstant: self.layout.iconHeight).isActive = true
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.urlView = {
                let view = UILabel()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.font = self.style.urlFont
                view.textColor = self.style.urlColor
                return view
            }()
            
            self.imageView = {
                let view = UIImageView()
                view.contentMode = .scaleAspectFit
                view.clipsToBounds = true
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.urlStackView.addArrangedSubview(self.iconView)
            self.urlStackView.addArrangedSubview(self.urlView)
            
            self.leftStackView.addArrangedSubview(self.titleView)
            self.leftStackView.addArrangedSubview(self.descriptionView)
            self.leftStackView.addArrangedSubview(self.urlStackView)
            
            self.contentView.addSubview(self.leftStackView)
            self.contentView.addSubview(self.imageView)
            
            self.addSubview(self.contentView)
            
            self.leftStackView.backgroundColor = .systemGray6
            self.imageView.backgroundColor = .systemGray2
        }
        
        /// Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.leftStackView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.commonInsets.left),
                    view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -self.layout.commonInsets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.commonInsets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.commonInsets.bottom)
                ])
            }
        }
        
        func addLayoutForImageView() {
            if let view = self.imageView, let superview = view.superview, let leftView = self.leftStackView {
                self.imageViewWidthConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: self.layout.imageSizeFactor)
                self.imageViewWidthConstraint?.isActive = true
                
                self.imageViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: self.layout.imageHeightConstant)
                self.imageViewHeightConstraint?.isActive = true
//                self.imageViewHeightConstraint?.priority = .defaultLow
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: self.layout.commonInsets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
                ])
            }
        }
        
        /// Configurations
        private func handle(_ value: BookmarkViewModel.Resource?) {
            guard let value = value else {
                print("value is nil!")
                return
            }
            switch value.state {
            case let .onlyURL(payload):
                self.urlView.text = payload.url
                self.titleView.isHidden = true
                self.descriptionView.isHidden = true
                self.urlView.isHidden = false
                self.iconView.isHidden = true
                self.urlStackView.isHidden = false
            case let .fetched(payload):
                self.titleView.text = payload.title
                self.descriptionView.text = payload.subtitle
                self.urlView.text = payload.url
                self.iconView.image = value.imageLoader?.iconProperty?.property
                self.imageView.image = value.imageLoader?.imageProperty?.property
                if payload.hasImage() {
                    self.addLayoutForImageView()
                }
                self.titleView.isHidden = false
                self.descriptionView.isHidden = false
                self.urlView.isHidden = false
                self.iconView.isHidden = self.iconView.image == nil
                self.urlStackView.isHidden = false
            default:
                self.titleView.isHidden = true
                self.descriptionView.isHidden = true
                self.urlView.isHidden = true
                self.iconView.isHidden = true
                self.urlStackView.isHidden = true
            }
        }
        
        func configured(_ stream: AnyPublisher<BookmarkViewModel.Resource?, Never>) {
            self.resourceStream = stream
            self.subscription = self.resourceStream.receiveOnMain().sink(receiveValue: { [weak self] (value) in
                print("state value: \(String(describing: value))")
                self?.resource = value
            })
        }
    }
}

// MARK: - UIKitViewWithBookmark / Apply
extension BlocksViews.Bookmark.UIKitViewWithBookmark {
    func apply(_ value: BookmarkViewModel.Resource?) {
        self.handle(value)
    }
}

// MARK: - UIKitView / Layout
private extension BlocksViews.Bookmark.UIKitView {
    struct Layout {
        var imageContentViewDefaultHeight: CGFloat = 250
        var imageViewTop: CGFloat = 4
        var emptyViewHeight: CGFloat = 52
        let bookmarkViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
    }
}

// MARK: - UIKitView / Resource
private extension BlocksViews.Bookmark.UIKitView {
    struct Resource {
        var emptyViewPlaceholderTitle = "Add a web bookmark"
        var emptyViewImagePath = "TextEditor/Style/Bookmark/Empty"
    }
}

// MARK: - UIKitView
private extension BlocksViews.Bookmark {
    class UIKitView: UIView {
        
        typealias EmptyView = BlocksViews.File.Base.TopUIKitEmptyView
                        
        var subscription: AnyCancellable?
        
        var layout: Layout = .init()
        var resource: Resource = .init()
                
        // MARK: Views
        var emptyView: EmptyView!
        var bookmarkView: UIKitViewWithBookmark!
                
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
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.bookmarkView = {
                let view = UIKitViewWithBookmark()
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor(hexString: "#DFDDD0").cgColor
                view.layer.cornerRadius = 4
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.emptyView = {
                let view = EmptyView()
                view.configured(.init(placeholderText: self.resource.emptyViewPlaceholderTitle, errorText: "", uploadingText: "", imagePath: self.resource.emptyViewImagePath))
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            addSubview(bookmarkView)
            addSubview(emptyView)
        }
        
        // MARK: Layout
        func addLayout() {
            self.addEmptyViewLayout()
        }
        
        func addBookmarkViewLayout() {
            bookmarkView.pinAllEdges(to: self, insets: layout.bookmarkViewInsets)
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
                        
        private func handle(_ resource: BookmarkViewModel.Resource) {
            switch resource.state {
            case .empty:
                self.addSubview(self.emptyView)
                self.addEmptyViewLayout()
                self.bookmarkView.isHidden = true
                self.emptyView.isHidden = false
            default:
                self.emptyView.removeFromSuperview()
                self.addBookmarkViewLayout()
                self.bookmarkView.isHidden = false
                self.emptyView.isHidden = true
            }
        }
                
        func configured(publisher: AnyPublisher<BookmarkViewModel.Resource?, Never>) -> Self {
            self.subscription = publisher.receiveOnMain().safelyUnwrapOptionals().sink { [weak self] (value) in
                self?.handle(value)
            }
            let resourcePublisher = publisher.receiveOnMain().eraseToAnyPublisher()
            _ = self.configured(published: resourcePublisher)
            return self
        }
        
        private func configured(published: AnyPublisher<BookmarkViewModel.Resource?, Never>) -> Self {
            self.bookmarkView.configured(published)
            return self
        }
    }
}

// MARK: UIKitView / Apply
extension BlocksViews.Bookmark.UIKitView {
    func apply(_ value: BookmarkViewModel.Resource?) {
        guard let value = value else { return }
        self.bookmarkView.apply(value)
        self.handle(value)
    }
    func apply(_ value: BlockContent.Bookmark) {
        let model = BookmarkViewModel.ResourceConverter.asOurModel(value)
        self.apply(model)
    }
}

// MARK: ContentConfiguration
extension BookmarkViewModel {
    
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
        fileprivate weak var contextMenuHolder: BookmarkViewModel?
        
        init(_ information: BlockInformation) {
            /// We should warn if we have incorrect content type (?)
            /// Don't know :(
            /// Think about failable initializer
            
            switch information.content {
            case .bookmark: break
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

// MARK: - ContentView
private extension BookmarkViewModel {
    final class ContentView: UIView & UIContentView {
        
        private enum Constants {
            static let topViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
        }
        
        private let topView = BlocksViews.Bookmark.UIKitView()
        private var imageSubscription: AnyCancellable?
        private var iconSubscription: AnyCancellable?
        private var currentConfiguration: ContentConfiguration
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                guard let configuration = newValue as? ContentConfiguration,
                      configuration != currentConfiguration else { return }
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
            topView.pinAllEdges(to: self, insets: Constants.topViewInsets)
        }
        
        private func handle(_ value: BookmarkViewModel.Resource?) {
            value?.imageLoader = self.currentConfiguration.contextMenuHolder?.imagesPublished
            self.topView.apply(value)
        }
        
        private func handle(_ value: BlockContent.Bookmark) {
            if self.iconSubscription.isNil {
                let item = self.currentConfiguration.contextMenuHolder?.imagesPublished.iconProperty?.stream.receiveOnMain().sink(receiveValue: { [value, weak self] (image) in
                    self?.handle(value)
                })
                self.iconSubscription = item
            }

            if self.imageSubscription.isNil {
                let item = self.currentConfiguration.contextMenuHolder?.imagesPublished.imageProperty?.stream.receiveOnMain().sink(receiveValue: { [value, weak self] (image) in
                    self?.handle(value)
                })
                self.imageSubscription = item
            }
            
            let model = BookmarkViewModel.ResourceConverter.asOurModel(value)
            self.handle(model)
        }
        
        private func applyNewConfiguration() {
            switch self.currentConfiguration.information.content {
            case let .bookmark(value): self.handle(value)
            default: return
            }
        }
    }
}
