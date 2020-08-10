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
        @Published private var statePublished: State?
        private var publisher: AnyPublisher<TopLevel.AliasesMap.BlockContent.Bookmark, Never> = .empty()
        
        override func makeUIView() -> UIView {
            UIKitView().configured(publisher: self.$statePublished.safelyUnwrapOptionals().eraseToAnyPublisher())
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
            case let .bookmark(value):
                switch value {
                case let .fetch(value):
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
                }
            default: return
            }
        }

        private func setup() {
            self.setupSubscribers()
        }
        
        func setupSubscribers() {
//            self.toolbarSubscription = self.toolbarActionSubject.sink { [weak self] (value) in
//                self?.handle(toolbarAction: value)
//            }
            let publisher = self.getBlock().didChangeInformationPublisher().map({ value -> TopLevel.AliasesMap.BlockContent.Bookmark? in
                switch value.content {
                case let .bookmark(value): return value
                default: return nil
                }
            }).safelyUnwrapOptionals().eraseToAnyPublisher()
            
            /// Also embed image data to state.            
            self.subscription = publisher.sink(receiveValue: { [weak self] (value) in
                print("bookmark value: \(String(describing: value))")
                let state = StateConverter.asOurModel(value)
                print("bookmark state: \(String(describing: state))")
                self?.statePublished = state
            })
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
private extension Namespace.ViewModel {
    enum StateConverter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Bookmark
        typealias OurModel = State
        static func asModel(_ value: OurModel) -> Model? {
            return nil
        }
        
        static func asOurModel(_ value: Model) -> OurModel? {
            if value.url.isEmpty {
                return .empty
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

private extension Namespace.ViewModel {
    enum State {
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
            
            func hasImage() -> Bool {
                self.image != nil
            }
        }

        case empty
        
        /// Do we need only url case?
        /// Not sure.
        case onlyURL(Payload)
        case fetched(Payload)
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
        var iconHeight: CGFloat = 24
    }
}

// MARK: - UIView / WithBookmark / Resource
private extension Namespace.UIKitViewWithBookmark {
    struct Resource {
        enum State {
            struct Payload {
                var url: String?
                var title: String?
                var subtitle: String?
                var imageURL: URL?
                var iconURL: URL?
                var imageData: Data?
                var iconData: Data?
                
                func hasImage() -> Bool { self.imageURL != nil }
            }
            
            case empty
            case onlyURL(Payload)
            case fetched(Payload)
        }
        
        var state: State = .empty
    }
}

// MARK: - UIView / WithBookmark
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
        var contentView: UIView!
        var titleView: UILabel!
        var descriptionView: UILabel!
        var iconView: UIImageView!
        var urlView: UILabel!
        
        var leftStackView: UIStackView!
        var urlStackView: UIStackView!
        
        var imageView: UIImageView!
        
        var imageViewConstraint: NSLayoutConstraint?
        
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
                view.contentMode = .center
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
                view.contentMode = .center
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
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: self.layout.commonInsets.left),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                ])
                
                self.imageViewConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: self.layout.imageSizeFactor)
            }
        }
        
        /// Configurations
        func handle(_ value: Resource?) {
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
                self.iconView.image = payload.iconData.flatMap(UIImage.init(data:))
                self.imageView.image = payload.imageData.flatMap(UIImage.init(data:))
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
                        
        private func handle(_ state: Namespace.ViewModel.State) {
            switch state {
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
        
        func configured(publisher: AnyPublisher<Namespace.ViewModel.State, Never>) -> Self {
            self.subscription = publisher.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.handle(value)
            }
            let resourcePublisher = publisher.receive(on: RunLoop.main).map({ value -> UIKitViewWithBookmark.Resource? in
                switch value {
                case .empty: return .init(state: .empty)
                case let .onlyURL(payload): return .init(state: .onlyURL(.init(url: payload.url)))
                case let .fetched(payload): return .init(state: .fetched(.init(url: payload.url, title: payload.title, subtitle: payload.subtitle, imageURL: payload.image?.url, iconURL: payload.icon?.url, imageData: payload.image?.data, iconData: payload.icon?.data)))
                }
            }).eraseToAnyPublisher()
            _ = self.configured(published: resourcePublisher)
            return self
        }
        
        func configured(published: AnyPublisher<UIKitViewWithBookmark.Resource?, Never>) -> Self {
            self.bookmarkView.configured(published)
            return self
        }
    }
}
