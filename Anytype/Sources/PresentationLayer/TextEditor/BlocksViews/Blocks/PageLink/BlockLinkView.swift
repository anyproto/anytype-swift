import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockLinkView: UIView, UIContentView {
    private var currentConfiguration: BlockLinkContentConfiguration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockLinkContentConfiguration else { return }
            guard currentConfiguration != configuration else { return }
            currentConfiguration = configuration
            apply(configuration.state)
        }
    }
    
    
    init(configuration: BlockLinkContentConfiguration) {
        currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        apply(configuration.state)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: - Internal functions
    func apply(_ state: BlockLinkState) {
        iconView.removeAllSubviews()
        iconView.addSubview(state.makeIconView()) {
            $0.pinToSuperview()
        }
        
        textView.attributedText = state.attributedTitle
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
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: iconView.trailingAnchor)
        }
    }
    
    // MARK: - Views
    private let contentView = UIView()
    
    private let iconView = UIView()
    
    private let textView: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.textContainerInset = Constants.textContainerInset
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
