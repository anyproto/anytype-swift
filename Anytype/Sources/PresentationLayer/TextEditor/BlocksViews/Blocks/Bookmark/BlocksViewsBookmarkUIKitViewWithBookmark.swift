//
//  BlocksViewsBookmarkUIKitViewWithBookmark.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import BlocksModels

// MARK: - UIKitViewWithBookmark
extension BlocksViews.Bookmark {
    class UIKitViewWithBookmark: UIView {
        /// Variables
        private var style: Style = .presentation
        
        private var layout: Layout = .init()
        
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

