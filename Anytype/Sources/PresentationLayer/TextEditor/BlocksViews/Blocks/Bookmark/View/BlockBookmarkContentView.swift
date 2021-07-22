import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkContentView: UIView & UIContentView {
    private var currentConfiguration: BlockBookmarkConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockBookmarkConfiguration,
                  configuration != currentConfiguration else { return }
            
            currentConfiguration = configuration
            apply(state: currentConfiguration.bookmarkData.blockBookmarkState)
        }
    }
    
    init(configuration: BlockBookmarkConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setup()
        
        apply(state: currentConfiguration.bookmarkData.blockBookmarkState)
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Not implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func apply(state: BlockBookmarkState) {
        bookmarkView.handle(state: state)
        handle(state: state)
    }
    
    private func setup() {
        addSubview(bookmarkView)
        addSubview(emptyView)
        
        bookmarkView.pinAllEdges(to: self, insets: Constants.Layout.bookmarkViewInsets)
    
        if let superview = emptyView.superview {
            let heightAnchor = emptyView.heightAnchor.constraint(equalToConstant: Constants.Layout.emptyViewHeight)
            let bottomAnchor = emptyView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            // We need priotity here cause cell self size constraint will conflict with ours
            bottomAnchor.priority = .init(750)
            
            NSLayoutConstraint.activate([
                emptyView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 20),
                emptyView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -20),
                emptyView.topAnchor.constraint(equalTo: superview.topAnchor),
                bottomAnchor,
                heightAnchor
            ])
        }
    }
                    
    private func handle(state: BlockBookmarkState) {
        switch state {
        case .empty:
            bookmarkView.isHidden = true
            emptyView.isHidden = false
        default:
            bookmarkView.isHidden = false
            emptyView.isHidden = true
        }
    }

    // MARK: - Views
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
        view.clipsToBounds = true
        return view
    }()
}

private extension BlockBookmarkContentView {
    enum Constants {
        enum Layout {
            static let emptyViewHeight: CGFloat = 52
            static let bookmarkViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
        }
        
        enum Resource {
            static let emptyViewPlaceholderTitle = "Add a web bookmark"
        }
    }
}
