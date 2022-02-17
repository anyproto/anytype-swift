import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockLinkView: UIView, BlockContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: BlockLinkContentConfiguration) {
        apply(configuration)
    }

    // MARK: - Internal functions
    func apply(_ configuration: BlockLinkContentConfiguration) {
        iconView.removeAllSubviews()
        iconView.addSubview(configuration.state.makeIconView()) {
            $0.pinToSuperview()
        }

        textView.setText(configuration.state.attributedTitle)
        textView.setLineBreakMode(.byTruncatingTail)
        deletedLabel.isHidden = !configuration.state.archived
    }
    
    // MARK: - Private functions
    
    private func setup() {
        addSubview(contentView) {
            $0.pinToSuperview(insets: Constants.contentInsets)
        }
        
        contentView.addSubview(iconView) {
            $0.pinToSuperview(excluding: [.right])
        }
        contentView.addSubview(textView) {
            $0.pinToSuperview(excluding: [.left, .right])
            $0.leading.equal(to: iconView.trailingAnchor)
        }
        contentView.addSubview(deletedLabel) {
            $0.pinToSuperview(excluding: [.left, .right])
            $0.trailing.equal(to: contentView.trailingAnchor)
            $0.leading.equal(to: textView.trailingAnchor)
        }
    }
    
    // MARK: - Views
    private let contentView = UIView()
    private let iconView = UIView()
    
    private let deletedLabel = DeletedLabel()
    
    private let textView: AnytypeLabel = {
        let view = AnytypeLabel(style: .body)
        view.isUserInteractionEnabled = false
        return view
    }()
}

// MARK: - Constants

private extension BlockLinkView {
    
    enum Constants {
        static let textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 8)
        static let contentInsets = UIEdgeInsets(top: 5, left: 20, bottom: -5, right: -20)
    }
    
}
