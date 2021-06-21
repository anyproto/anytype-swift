//
//  BlocksViewsBookmarkUIKitView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import BlocksModels

// MARK: - UIKitView
extension BlocksViews.Bookmark {
    
    class UIKitView: UIView {
        
        typealias EmptyView = BlocksViews.File.Base.TopUIKitEmptyView
                        
        var subscription: AnyCancellable?
        
        private var layout: Layout = .init()
        private var resource: Resource = .init()
                
        // MARK: Views
        var emptyView: EmptyView!
        var bookmarkView: BlocksViews.Bookmark.UIKitViewWithBookmark!
                
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
