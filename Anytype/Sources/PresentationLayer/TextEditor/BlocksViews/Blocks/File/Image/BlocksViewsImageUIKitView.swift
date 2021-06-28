import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

extension BlocksViewsImageUIKitView {
    enum Layout {
        static let imageContentViewDefaultHeight: CGFloat = 250
        static let imageViewTop: CGFloat = 4
        static let emptyViewHeight: CGFloat = 52
        static let emptyViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        static let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    }
    
    enum Constants {
        static let emptyViewPlaceholderTitle = "Add link or Upload a picture"
    }
}

class BlocksViewsImageUIKitView: UIView {
    var subscription: AnyCancellable?
    
    var setupImageSubscription: AnyCancellable?
    
    // MARK: Views
    var imageContentView: UIView!
    var imageContentViewHeight: NSLayoutConstraint?
    var imageView: UIImageView!
    
    var emptyView: BlocksViewsBaseFileTopUIKitEmptyView!
    
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
            let view = BlocksViewsBaseFileTopUIKitEmptyView(
                viewData: .init(
                    image: UIImage.blockFile.empty.image,
                    placeholderText: Constants.emptyViewPlaceholderTitle
                )
            )
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
            imageContentViewHeight = view.heightAnchor.constraint(equalToConstant: Layout.imageContentViewDefaultHeight)
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
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: Layout.imageViewTop),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    func addEmptyViewLayout() {
        if let view = self.emptyView, let superview = view.superview {
            let heightAnchor = view.heightAnchor.constraint(equalToConstant: Layout.emptyViewHeight)
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
    
    func setupImage(_ file: BlockFile) {
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
    
    private func handleFile(_ file: BlockFile) {
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
    
    func configured(publisher: AnyPublisher<BlockFile, Never>) -> Self {
        self.subscription = publisher.receiveOnMain().sink { [weak self] (value) in
            self?.handleFile(value)
        }
        return self
    }
}
