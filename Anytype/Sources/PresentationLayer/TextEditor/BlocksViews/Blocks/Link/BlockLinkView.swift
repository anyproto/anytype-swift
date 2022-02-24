import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockLinkView: UIView, BlockContentView {
    
    // MARK: - Views
    
    private let contentView = UIView()
    private let iconContainerView = UIView()
    
    private let deletedLabel = DeletedLabel()
    
    private let textView: AnytypeLabel = {
        let view = AnytypeLabel(style: .body)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var textViewLeadingToContentViewConstraint: NSLayoutConstraint?
    private var textViewLeadingToIconViewConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Internal functions
    
    func update(with configuration: BlockLinkContentConfiguration) {
        apply(configuration)
    }

    func apply(_ configuration: BlockLinkContentConfiguration) {
        iconContainerView.removeAllSubviews()
        if let iconView = configuration.state.makeIconView() {
            iconContainerView.addSubview(iconView) {
                $0.pinToSuperview()
            }
            iconContainerView.isHidden = false
            textViewLeadingToContentViewConstraint?.isActive = false
            textViewLeadingToIconViewConstraint?.isActive = true
        } else {
            iconContainerView.isHidden = true
            textViewLeadingToContentViewConstraint?.isActive = true
            textViewLeadingToIconViewConstraint?.isActive = false
        }

        textView.setText(configuration.state.attributedTitle)
        textView.setLineBreakMode(.byTruncatingTail)
        deletedLabel.isHidden = !configuration.state.archived
    }
    
}

// MARK: - Private functions

private extension BlockLinkView {
    
    func setup() {
        addSubview(contentView) {
            $0.pinToSuperview(insets: Constants.contentInsets)
        }
        
        contentView.addSubview(iconContainerView) {
            $0.pinToSuperview(excluding: [.right])
        }
        contentView.addSubview(textView) {
            $0.pinToSuperview(excluding: [.left, .right])
            self.textViewLeadingToContentViewConstraint = $0.leading.equal(to: contentView.leadingAnchor, activate: false)
            self.textViewLeadingToIconViewConstraint = $0.leading.equal(to: iconContainerView.trailingAnchor, constant: 8)
        }
        contentView.addSubview(deletedLabel) {
            $0.pinToSuperview(excluding: [.left, .right])
            $0.trailing.equal(to: contentView.trailingAnchor)
            $0.leading.greaterThanOrEqual(to: textView.trailingAnchor)
        }
    }
    
}
// MARK: - Constants

private extension BlockLinkView {
    
    enum Constants {
        static let textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 8)
        static let contentInsets = UIEdgeInsets(top: 5, left: 20, bottom: -5, right: -20)
    }
    
}
