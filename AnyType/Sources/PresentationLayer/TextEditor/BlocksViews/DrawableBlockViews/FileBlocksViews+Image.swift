//
//  ImageBlocksViews+Image.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: ViewModel
extension FileBlocksViews.Image {
    class BlockViewModel: FileBlocksViews.Base.BlockViewModel {
      
        var fileBlock: BlockType.File? {
            didSet {
                self.state = fileBlock?.state
            }
        }
        
        fileprivate var fileView: FileImageBlockView!
        private var subscription: AnyCancellable?
        
        override func makeUIView() -> UIView {
            fileView = FileImageBlockView().configured(with: self.fileBlock)
            return fileView
        }
        
        // TODO: Change it in future tasks
        override func indentationLevel() -> UInt {
            return 0
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
                // we should show image picker
                self.send(userAction: .specific(.file(.image(.shouldShowImagePicker(self.getRealBlock())))))
            }
        }
        
        private func setup() {
            switch getRealBlock().information.content {
                case let .file(blockType):
                    self.fileBlock = blockType
                default: return
            }
            
            handleEvents()
        }
        
        func update(to state: BlockType.File.State, hash: String, name: String) {
            self.update { (block) in
                switch block.information.content {
                    case let .file(value):
                    var value = value
                    value.contentType = .image
                    value.hash = hash
                    value.name = name
                    value.state = state
                    
                    block.information.content = .file(value)
                    updateFileBlock(value)
                    default: return
                }
            }
        }
        
        private func updateFileBlock(_ block: BlockType.File) {
            self.fileBlock = block
            
            // TODO: Make listener for update state in view later
            if self.fileView != nil {
                self.fileView.block = block
            }
        }
        
        private func handleEvents() {
            subscription = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
                .compactMap { notification in
                    return notification.object as? Anytype_Event
            }
            .map { $0.messages }
            .map {
                $0.filter { message in
                    guard let value = message.value else { return false }
                    
                    if case Anytype_Event.Message.OneOf_Value.blockSetFile = value {
                        return true
                    }
                    return false
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] events in
                if let event = events.filter({$0.blockSetFile.id == self?.blockId }).first {
                    let block = event.blockSetFile
                
                    switch block.state.value {
                    case .done:
                        self?.update(to: .done, hash: block.hash.value, name: block.name.value)
                    case .uploading:
                        self?.update(to: .uploading, hash: block.hash.value, name: block.name.value)
                    case .error, .UNRECOGNIZED(_):
                        self?.update(to: .error, hash: block.hash.value, name: block.name.value)
                    case .empty: break
                        // Nothing to do
                    }
                }
            }
        }
    }
}

// MARK: - UIView
private extension FileBlocksViews.Image {
    class FileImageBlockView: UIView {
        
        struct Layout {
            var imageViewHeightMultiplier: CGFloat = 0.6
            var imageViewTop: CGFloat = 4
            var emptyViewHeight: CGFloat = 52
        }
               
        var layout: Layout = .init()
        
        // MARK: Views
        var imageContentView: UIView!
        var imageView: UIImageView!
        
        var emptyView: EmptyView!
        
        var block: BlockType.File? {
            didSet {
                blockState = block?.state
            }
        }
        var blockState: BlockType.File.State? {
            didSet {
                handleState()
            }
        }

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

            self.addSubview(emptyView)
        }
        
        // MARK: Layout
        func addLayout() {
            addEmptyViewLayout()
        }
        
        func addImageViewLayout() {
            if let view = self.imageContentView, let superview = view.superview {
                let heightAnchor = view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: self.layout.imageViewHeightMultiplier)
                let bottomAnchor = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                    bottomAnchor.priority = UILayoutPriority(750)

                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    bottomAnchor,
                    heightAnchor
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
                bottomAnchor.priority = UILayoutPriority(750)
                  
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
            if imageContentView != nil {
                self.imageContentView.removeFromSuperview()
            }
            if emptyView != nil {
                self.emptyView.removeFromSuperview()
            }
        }
     
        func setupImage() {
            guard let blockHash = block?.hash else { return }
            
            _ = MiddlewareConfigurationService().obtainConfiguration().sink(receiveCompletion: { _ in }, receiveValue: { (config) in
                
                guard let url = URL(string: config.gatewayURL + "/image/" + blockHash) else { return }
                
                // TODO: WIll change loading to new ImageLoader class
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            if let imageView = self.imageView {
                                imageView.image = UIImage(data: data)
                            }
                        }
                    }
                }
            })
        }
        
        private func handleState() {
            self.removeViewsIfExist()
            
            switch blockState  {
            case .empty:
                self.setupEmptyView()
                self.addEmptyViewLayout()
            case .uploading:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.setupUploadingView()
            case .done:
                 self.setupImageView()
                 self.addImageViewLayout()
                 self.setupImage()
            case .error:
                self.setupEmptyView()
                self.addEmptyViewLayout()
                self.emptyView.setupErrorView()
            case .none: break
                // Nothing to do
            }
        }

        // MARK: Configured
        func configured(with block: BlockType.File?) -> Self {
            if let fileBlock = block {
                self.block = fileBlock
            }
            return self
        }
        
    }
}

// MARK: - UIView
private extension FileBlocksViews.Image {
    class EmptyView: UIView {
        
        struct Layout {
            var placeholderViewInsets: UIEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
            var placeholderIconLeading: CGFloat = 12
            var placeholderLabelSpacing: CGFloat = 4
            var activityIndicatorTrailing: CGFloat = 18
        }
        
        struct Resource {
            var placeholderText: String = "Upload or Embed a file"
            var errorText: String = "Some error. Try again later"
            var uploadingText: String = "Uploading..."
        }
        
        var layout: Layout = .init()
        var resource: Resource = .init()
        
        // MARK: Views
        var contentView: UIView!
        
        var placeholderView: UIView!
        var placeholderLabel: UILabel!
        var placeholderIcon: UIImageView!
        
        var activityIndicator: UIActivityIndicatorView!
        
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
            self.setupEmptyView()
        }
        
        func setupEmptyView() {
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
                label.text = resource.placeholderText
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
                imageView.image = #imageLiteral(resourceName: "block_file_image_icon")
                imageView.contentMode = .scaleAspectFit
                return imageView
            }()
            
            self.placeholderView.addSubview(placeholderLabel)
            self.placeholderView.addSubview(placeholderIcon)
            self.addSubview(placeholderView)
            self.addSubview(activityIndicator)
        }
        
        func setupErrorView() {
            self.placeholderLabel.text = resource.errorText
            self.activityIndicator.isHidden = true
        }
       
        func setupUploadingView() {
            self.placeholderLabel.text = resource.uploadingText
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    
        // MARK: Layout
        func addLayout() {
            
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
    }
}
