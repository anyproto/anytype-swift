//
//  BlocksViews+New+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.File
fileprivate typealias FileNamespace = Namespace.Base

extension Namespace {
    enum File {} // -> File.ContentType.file
    enum Image {} // -> Image.ContentType.image
    enum Base {}
}

extension FileNamespace {
    class ViewModel: BlocksViews.New.Base.ViewModel {
        typealias File = TopLevel.AliasesMap.BlockContent.File
        typealias State = File.State
        var subscriptions: Set<AnyCancellable> = []
        @Published var state: State? { willSet { self.objectWillChange.send() } }
    }
}

// MARK: - UIView
extension FileNamespace {
    class TopUIKitEmptyView: UIView {
        
        struct Layout {
            var placeholderViewInsets: UIEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
            var placeholderIconLeading: CGFloat = 12
            var placeholderLabelSpacing: CGFloat = 4
            var activityIndicatorTrailing: CGFloat = 18
        }
        
        struct Resource {
            var placeholderText: String = "Add link or Upload a file"
            var errorText: String = "Some error. Try again later"
            var uploadingText: String = "Uploading..."
            
            var imagePath: String = "TextEditor/Style/File/Empty/File"
        }
        
        var layout: Layout = .init()
        var resource: Resource = .init() {
            didSet {
                self.placeholderLabel.text = self.resource.placeholderText
                self.placeholderIcon.image = UIImage.init(named: self.resource.imagePath)
            }
        }
        
        // MARK: - Publishers
        private var subscription: AnyCancellable?
        @Published private var hasError: Bool = false
        
        // MARK: Views
        private var contentView: UIView!
        
        private var placeholderView: UIView!
        private var placeholderLabel: UILabel!
        private var placeholderIcon: UIImageView!
        
        private var activityIndicator: UIActivityIndicatorView!
        
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
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.setupEmptyView()
        }
        
        private func setupEmptyView() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            // TODO: Move colors to service or smt
            self.placeholderView = {
                let view = UIView()
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor(hexString: "#DFDDD0").cgColor
                view.layer.cornerRadius = 4
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.placeholderLabel = {
                let label = UILabel()
                label.text = self.resource.placeholderText
                label.textColor = UIColor(hexString: "#ACA996")
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            
            self.activityIndicator = {
                let loader = UIActivityIndicatorView()
                loader.color = UIColor(hexString: "#ACA996")
                loader.hidesWhenStopped = true
                loader.translatesAutoresizingMaskIntoConstraints = false
                return loader
            }()
            
            self.placeholderIcon = {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = UIImage.init(named: self.resource.imagePath)
                imageView.contentMode = .scaleAspectFit
                return imageView
            }()
            
            self.placeholderView.addSubview(placeholderLabel)
            self.placeholderView.addSubview(placeholderIcon)
            self.addSubview(placeholderView)
            self.addSubview(activityIndicator)
        }
                
        // MARK: Layout
        private func addLayout() {
            
            if let view = self.placeholderView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.placeholderViewInsets.left),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.placeholderViewInsets.right),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.layout.placeholderViewInsets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -self.layout.placeholderViewInsets.bottom)
                    
                ])
            }
            
            if let view = self.placeholderIcon, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.placeholderIconLeading),
                    view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                    view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
                ])
            }
            
            if let view = self.placeholderLabel, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: self.placeholderIcon.trailingAnchor, constant: self.layout.placeholderLabelSpacing),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            
            if let view = self.activityIndicator, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.activityIndicatorTrailing),
                    view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                    view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
                ])
            }
            
        }
        
        // MARK: - Actions
        
        func toErrorView() {
            self.placeholderLabel.text = self.resource.errorText
            self.activityIndicator.isHidden = true
        }
        
        func toUploadingView() {
            self.placeholderLabel.text = self.resource.uploadingText
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        // MARK: - Configurations
        
        func configured(_ stream: Published<Bool>) {
            self._hasError = stream
            self.subscription = self.$hasError.sink(receiveValue: { [weak self] (value) in
                if value {
                    self?.toErrorView()
                }
                else {
                    self?.toUploadingView()
                }
            })
        }
        
        func configured(_ resource: Resource) {
            self.resource = resource
        }
    }
}
