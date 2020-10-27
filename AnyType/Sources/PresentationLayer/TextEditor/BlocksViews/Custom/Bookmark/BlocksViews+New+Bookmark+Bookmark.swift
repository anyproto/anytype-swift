//
//  BlocksViews+New+Bookmark+Bookmark.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices

fileprivate typealias Namespace = BlocksViews.New.Bookmark.Bookmark

private extension Logging.Categories {
    static let blocksViewsNewBookmarkBookmark: Self = "BlocksViews.New.Bookmark.Bookmark"
}

// TODO: Rethink.
// Maybe we should use SwiftUI which will be embedded in UIKit.
// In this case we will receive simple updates of all views.

// MARK: ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.Bookmark.Base.ViewModel {
        private var service: ServiceLayerModule.BookmarkBlockActionsService = .init()
        
        private var subscription: AnyCancellable?
        private var toolbarSubscription: AnyCancellable?
        @Published private var resourcePublished: Resource?
        var imagesPublished: Resource.ImageLoader = .init()
        private var publisher: AnyPublisher<TopLevel.AliasesMap.BlockContent.Bookmark, Never> = .empty()
        
        override func makeUIView() -> UIView {
            UIKitView().configured(publisher: self.$resourcePublished.eraseToAnyPublisher())
        }
        
        override func makeContentConfiguration() -> UIContentConfiguration {
            var configuration = ContentConfiguration.init(self.getBlock().blockModel.information)
            configuration.contextMenuHolder = self
            return configuration
        }
        
        // MARK: Subclassing
        override init(_ block: BlockModel) {
            super.init(block)
            self.setup()
        }
        
        // MARK: Subclassing / Events
        override func handle(event: BlocksViews.UserEvent) {
            switch event {
            case .didSelectRowInTableView:
                // we should show image picker only for empty state
                // TODO: Need to think about error state, reload or something
                
                // Think what we should check...
                // Empty URL?
                if case let .bookmark(value) = self.getBlock().blockModel.information.content, !value.url.isEmpty {
                    let logger = Logging.createLogger(category: .blocksViewsNewBookmarkBookmark)
                    os_log(.info, log: logger, "User pressed on BookmarkBlocksViews when our state is not empty. Our URL is not empty")
                    return
                }
                                
                self.send(userAction: .toolbars(.bookmark(.init(output: self.toolbarActionSubject))))
            }
        }
        
        override func handle(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
            switch toolbarAction {
            case let .bookmark(.fetch(value)):
                self.update { (block) in
                    switch block.blockModel.information.content {
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
        
        /// TODO: Fix it.
        /// We should add diffable here.
        /// It will save us from UI glitches when scrolling...
        /// OR
        /// We could use SwiftUI for these views...
        ///
        override func makeDiffable() -> AnyHashable {
            let diffable = super.makeDiffable()
            if case let .bookmark(value) = self.getBlock().blockModel.information.content {
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
            self.publisher = self.getBlock().didChangeInformationPublisher().map({ value -> TopLevel.AliasesMap.BlockContent.Bookmark? in
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
                .create(action: .general(.moveTo)),
                .create(action: .specific(.turnInto)),
            ])
        }
    }
}

// MARK: - State Converter
extension Namespace.ViewModel {
    enum ResourceConverter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Bookmark
        typealias OurModel = Resource
        static func asModel(_ value: OurModel) -> Model? {
            return nil
        }
        
        static func asOurModel(_ value: Model) -> OurModel? {
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

// MARK: - ViewModel / Downloading Images
private extension Namespace.ViewModel {}

// MARK: - Resource
extension Namespace.ViewModel {
    class Resource {
        
        class ImageLoader {
            /// I want to subscribe on current value subject, lol.
            var imageProperty: CoreLayer.Network.Image.Property?
            var iconProperty: CoreLayer.Network.Image.Property?
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
            
            func hasImage() -> Bool { self.image != nil }
            func hasIcon() -> Bool { self.icon != nil }
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
private extension Namespace.UIKitViewWithBookmark {
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
            case .presentation: return .black
            }
        }
        var subtitleColor: UIColor {
            switch self {
            case .presentation: return .gray
            }
        }
        var urlColor: UIColor {
            switch self {
            case .presentation: return .black
            }
        }
    }
}

// MARK: - UIView / WithBookmark / Layout
private extension Namespace.UIKitViewWithBookmark {
    struct Layout {
        var commonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        var spacing: CGFloat = 5
        var imageSizeFactor: CGFloat = 1 / 3
        var imageHeightConstant: CGFloat = 150
        var iconHeight: CGFloat = 24
    }
}

// MARK: - UIView / WithBookmark / Resource
private extension Namespace.UIKitViewWithBookmark {
    typealias Resource = Namespace.ViewModel.Resource
}

// MARK: - UIKitViewWithBookmark
private extension Namespace {
    class UIKitViewWithBookmark: UIView {
        /// Variables
        var style: Style = .presentation
        
        var layout: Layout = .init()
        
        /// Publishers
        private var subscription: AnyCancellable?
        private var resourceStream: AnyPublisher<Resource?, Never> = .empty()
        @Published var resource: Resource? {
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
            
            self.leftStackView.backgroundColor = .green
            self.imageView.backgroundColor = .red
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
        private func handle(_ value: Resource?) {
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
        
        func configured(_ stream: AnyPublisher<Resource?, Never>) {
            self.resourceStream = stream
            self.subscription = self.resourceStream.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (value) in
                print("state value: \(String(describing: value))")
                self?.resource = value
            })
        }
    }
}

// MARK: - UIKitViewWithBookmark / Apply
extension Namespace.UIKitViewWithBookmark {
    func apply(_ value: Resource?) {
        self.handle(value)
    }
}

// MARK: - UIKitView / Layout
private extension Namespace.UIKitView {
    struct Layout {
        var imageContentViewDefaultHeight: CGFloat = 250
        var imageViewTop: CGFloat = 4
        var emptyViewHeight: CGFloat = 52
    }
}

// MARK: - UIKitView / Resource
private extension Namespace.UIKitView {
    struct Resource {
        var emptyViewPlaceholderTitle = "Add a web bookmark"
        var emptyViewImagePath = "TextEditor/Style/Bookmark/Empty"
    }
}

// MARK: - UIKitView
private extension Namespace {
    class UIKitView: UIView {
        
        typealias EmptyView = BlocksViews.New.File.Base.TopUIKitEmptyView
                        
        var subscription: AnyCancellable?
        
        var layout: Layout = .init()
        var resource: Resource = .init()
                
        // MARK: Views
        var contentView: UIView!
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
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
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
            
            self.contentView.addSubview(self.bookmarkView)
            self.contentView.addSubview(self.emptyView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            self.addEmptyViewLayout()
        }
        
        func addBookmarkViewLayout() {
            if let view = self.bookmarkView, let superview = view.superview {
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                bottomAnchor.priority = .init(750)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
//                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                    bottomAnchor
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
                        
        private func handle(_ resource: Namespace.ViewModel.Resource) {
            switch resource.state {
            case .empty:
                self.contentView.addSubview(self.emptyView)
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
                
        func configured(publisher: AnyPublisher<Namespace.ViewModel.Resource?, Never>) -> Self {
            self.subscription = publisher.receive(on: RunLoop.main).safelyUnwrapOptionals().sink { [weak self] (value) in
                self?.handle(value)
            }
            let resourcePublisher = publisher.receive(on: RunLoop.main).eraseToAnyPublisher()
            _ = self.configured(published: resourcePublisher)
            return self
        }
        
        private func configured(published: AnyPublisher<UIKitViewWithBookmark.Resource?, Never>) -> Self {
            self.bookmarkView.configured(published)
            return self
        }
    }
}

// MARK: UIKitView / Apply
extension Namespace.UIKitView {
    func apply(_ value: Namespace.ViewModel.Resource?) {
        guard let value = value else { return }
        self.bookmarkView.apply(value)
        self.handle(value)
    }
    func apply(_ value: TopLevel.AliasesMap.BlockContent.Bookmark) {
        let model = Namespace.ViewModel.ResourceConverter.asOurModel(value)
        self.apply(model)
    }
}

// MARK: ContentConfiguration
extension Namespace.ViewModel {
    
    /// As soon as we have builder in this type ( makeContentView )
    /// We could map all states ( for example, image has several states ) to several different ContentViews.
    ///
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.container == rhs.container
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.container)
        }
        
        typealias HashableContainer = TopLevel.AliasesMap.BlockInformationUtilities.AsHashable
        var information: Information {
            self.container.value
        }
        private var container: HashableContainer
        fileprivate weak var contextMenuHolder: Namespace.ViewModel?
        
        init(_ information: Information) {
            /// We should warn if we have incorrect content type (?)
            /// Don't know :(
            /// Think about failable initializer
            
            switch information.content {
            case .bookmark: break
            default:
                let logger = Logging.createLogger(category: .blocksViewsNewBookmarkBookmark)
                os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
                break
            }
            
            self.container = .init(value: information)
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            let view = ContentView(configuration: self)
            self.contextMenuHolder?.addContextMenu(view)
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
    class ContentView: UIView & UIContentView {
        
        struct Layout {
            let insets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        typealias TopView = Namespace.UIKitView
        
        /// Views
        private var topView: TopView = .init()
        private var contentView: UIView = .init()
        
        /// Subscriptions
        private var imageSubscription: AnyCancellable?
        private var iconSubscription: AnyCancellable?
        
        /// Others
//        var resource: Namespace.UIKitView.Resource = .init()
        var layout: Layout = .init()
                
        /// Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        private func setupUIElements() {
            /// Top most ContentView should have .translatesAutoresizingMaskIntoConstraints = true
            self.translatesAutoresizingMaskIntoConstraints = true

            [self.contentView, self.topView].forEach { (value) in
                value.translatesAutoresizingMaskIntoConstraints = false
            }
            
            /// View hierarchy
            self.contentView.addSubview(self.topView)
            self.addSubview(self.contentView)
        }
        
        private func addLayout() {
            if let superview = self.contentView.superview {
                let view = self.contentView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.insets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.insets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.insets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.insets.bottom),
                ])
            }
            
            if let superview = self.topView.superview {
                let view = self.topView
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                ])
            }
        }
        
        /// Handle
        private func handle(_ value: Namespace.ViewModel.Resource?) {
            value?.imageLoader = self.currentConfiguration.contextMenuHolder?.imagesPublished
            self.topView.apply(value)
        }
        
        private func handle(_ value: Block.Content.ContentType.Bookmark) {
            /// Do something
            /// We should reload data if text are not equal
            ///
            ///
            // configure resource and subscribe on it.
            if self.iconSubscription == nil {
                let item = self.currentConfiguration?.contextMenuHolder?.imagesPublished.iconProperty?.stream.receive(on: RunLoop.main).sink(receiveValue: { [value, weak self] (image) in
                    self?.handle(value)
                })
                self.iconSubscription = item
            }

            if self.imageSubscription == nil {
                let item = self.currentConfiguration?.contextMenuHolder?.imagesPublished.imageProperty?.stream.receive(on: RunLoop.main).sink(receiveValue: { [value, weak self] (image) in
                    self?.handle(value)
                })
                self.imageSubscription = item
            }
            
            let model = Namespace.ViewModel.ResourceConverter.asOurModel(value)
            self.handle(model)
        }
        
        /// Cleanup
        private func cleanupOnNewConfiguration() {
            /// Cleanup subscriptions.
        }
        
        /// Initialization
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// ContentView
        var currentConfiguration: ContentConfiguration!
        var configuration: UIContentConfiguration {
            get { self.currentConfiguration }
            set {
                /// apply configuration
                guard let configuration = newValue as? ContentConfiguration else { return }
                self.apply(configuration: configuration)
            }
        }

        init(configuration: ContentConfiguration) {
            super.init(frame: .zero)
            self.setup()
            self.apply(configuration: configuration)
        }
        
        private func apply(configuration: ContentConfiguration, forced: Bool) {
            if forced {
                self.currentConfiguration?.contextMenuHolder?.addContextMenu(self)
            }
        }
        
        private func apply(configuration: ContentConfiguration) {
            self.apply(configuration: configuration, forced: true)
            guard self.currentConfiguration != configuration else { return }
            
            self.currentConfiguration = configuration
            
            self.cleanupOnNewConfiguration()
            self.invalidateIntrinsicContentSize()
            
            switch self.currentConfiguration.information.content {
            case let .bookmark(value): self.handle(value)
            default: return
            }
        }
    }
}
