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
    
    final class UIKitView: UIView {

        private var emptyView: BlocksFileEmptyView!
        private var bookmarkView: BlocksViews.Bookmark.UIKitViewWithBookmark!
                
        private var subscription: AnyCancellable?
        
        // MARK: - Initializers
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: - Internal functions
        
        func configured(publisher: AnyPublisher<BookmarkViewModel.Resource?, Never>) -> Self {
            subscription = publisher
                .receiveOnMain()
                .safelyUnwrapOptionals()
                .sink { [weak self] value in
                    self?.handle(value)
                }
            
            let resourcePublisher = publisher
                .receiveOnMain()
                .eraseToAnyPublisher()
            bookmarkView.configured(resourcePublisher)
            
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
    
    func apply(_ value: BlockBookmark) {
        let model = BookmarkViewModel.ResourceConverter.asOurModel(value)
        self.apply(model)
    }
    
}

private extension BlocksViews.Bookmark.UIKitView {
    
    // MARK: Setup
    func setup() {
        setupUIElements()
        addLayout()
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        // Default behavior
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.bookmarkView = {
            let view = BlocksViews.Bookmark.UIKitViewWithBookmark()
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.grayscale30.cgColor
            view.layer.cornerRadius = 4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.emptyView = {
            let view = BlocksFileEmptyView(
                viewData: .init(
                    image: UIImage.blockFile.empty.bookmark,
                    placeholderText: Constants.Resource.emptyViewPlaceholderTitle
                )
            )
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
        bookmarkView.pinAllEdges(to: self, insets: Constants.Layout.bookmarkViewInsets)
    }
    
    func addEmptyViewLayout() {
        if let view = self.emptyView, let superview = view.superview {
            let heightAnchor = view.heightAnchor.constraint(equalToConstant: Constants.Layout.emptyViewHeight)
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
                    
    func handle(_ resource: BookmarkViewModel.Resource) {
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

}

// MARK: - Private extension

private extension BlocksViews.Bookmark.UIKitView {
    
    enum Constants {
        enum Layout {
            static let emptyViewHeight: CGFloat = 52
            static let bookmarkViewInsets = UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: -10,
                right: 0
            )
        }
        
        enum Resource {
            static let emptyViewPlaceholderTitle = "Add a web bookmark"
        }
    }
    
}
