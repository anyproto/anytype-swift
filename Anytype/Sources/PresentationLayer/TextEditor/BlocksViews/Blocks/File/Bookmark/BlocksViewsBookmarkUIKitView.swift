import Combine
import UIKit
import BlocksModels
    
final class BlocksViewsBookmarkUIKitView: UIView {

    private var emptyView: BlocksFileEmptyView!
    private var bookmarkView: BlocksViewsBookmarkUIKitViewWithBookmark!
            
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

// MARK: UIKitView / Apply
extension BlocksViewsBookmarkUIKitView {
    
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

private extension BlocksViewsBookmarkUIKitView {
    
    func setup() {
        setupUIElements()
        addEmptyViewLayout()
    }
    
    func setupUIElements() {
        // Default behavior
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.bookmarkView = {
            let view = BlocksViewsBookmarkUIKitViewWithBookmark()
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

private extension BlocksViewsBookmarkUIKitView {
    
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
