import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkContainerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let emptyView: BlocksFileEmptyView = {
        let view = BlocksFileEmptyView(
            viewData: .init(
                image: UIImage.blockFile.empty.bookmark,
                placeholderText: Constants.Resource.emptyViewPlaceholderTitle
            )
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bookmarkView: BlockBookmarkView = {
        let view = BlockBookmarkView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayscale30.cgColor
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: UIKitView / Apply
extension BlockBookmarkContainerView {
    
    func apply(state: BlockBookmarkState) {
        bookmarkView.handle(state: state)
        handle(state: state)
    }
    
    func updateIcon(icon: UIImage) {
        bookmarkView.updateIcon(icon: icon)
    }
    
    func updateImage(image: UIImage) {
        bookmarkView.updateImage(image: image)
    }
}

private extension BlockBookmarkContainerView {
    
    func setup() {
        setupUIElements()
        addBookmarkViewLayout()
        addEmptyViewLayout()
    }
    
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bookmarkView)
        addSubview(emptyView)
    }
    
    func addBookmarkViewLayout() {
        bookmarkView.pinAllEdges(to: self, insets: Constants.Layout.bookmarkViewInsets)
    }
    
    func addEmptyViewLayout() {
        if let superview = emptyView.superview {
            let heightAnchor = emptyView.heightAnchor.constraint(equalToConstant: Constants.Layout.emptyViewHeight)
            let bottomAnchor = emptyView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            // We need priotity here cause cell self size constraint will conflict with ours
            bottomAnchor.priority = .init(750)
            
            NSLayoutConstraint.activate([
                emptyView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                emptyView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                emptyView.topAnchor.constraint(equalTo: superview.topAnchor),
                bottomAnchor,
                heightAnchor
            ])
        }
    }
                    
    func handle(state: BlockBookmarkState) {
        switch state {
        case .empty:
            bookmarkView.isHidden = true
            emptyView.isHidden = false
        default:
            bookmarkView.isHidden = false
            emptyView.isHidden = true
        }
    }

}

private extension BlockBookmarkContainerView {
    enum Constants {
        enum Layout {
            static let emptyViewHeight: CGFloat = 52
            static let bookmarkViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        }
        
        enum Resource {
            static let emptyViewPlaceholderTitle = "Add a web bookmark"
        }
    }
}
