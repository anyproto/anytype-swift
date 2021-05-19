import Foundation
import UIKit
import Combine

final class DocumentIconEmojiView: UIView {
    
    var onUserAction: ((DocumentIconViewUserAction) -> Void)?
    
    // MARK: - Private properties
    
    private let emojiLabel: UILabel = UILabel()
        
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpView()
    }

}

// MARK: - ConfigurableView

extension DocumentIconEmojiView: ConfigurableView {
    
    func configure(model: IconEmoji) {
        emojiLabel.text = model.value
    }
    
}

// MARK: - Private extension

private extension DocumentIconEmojiView {
    
    func setUpView() {
        backgroundColor = .grayscale10
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius

        // Setup action menu
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        
        
        configureEmojiLabel()
        
        setUpLayout()
    }
    
    func configureEmojiLabel() {
        emojiLabel.backgroundColor = .grayscale10
        emojiLabel.font = .systemFont(ofSize: 64) // Used only for emoji
        emojiLabel.textAlignment = .center
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.isUserInteractionEnabled = false
    }
    
    func setUpLayout() {
        addSubview(emojiLabel)
        emojiLabel.pinAllEdges(to: self)
        
        layoutUsing.anchors {
            $0.size(Constants.size)
        }
    }
    
}

// MARK: - UIContextMenuInteractionDelegate

extension DocumentIconEmojiView: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let actions = DocumentIconViewUserAction.allCases.map { action in
            UIAction(
                title: action.title,
                image: action.icon
            ) { [weak self ] _ in
                self?.onUserAction?(action)
            }
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { suggestedActions in
                UIMenu(
                    title: "",
                    children: actions
                )
            }
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        let targetedView: UIView = self

        parameters.visiblePath = UIBezierPath(
            roundedRect: targetedView.bounds,
            cornerRadius: targetedView.layer.cornerRadius
        )

        return UITargetedPreview(view: targetedView, parameters: parameters)
    }

}

// MARK: - Constants

private extension DocumentIconEmojiView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 20
        static let size = CGSize(width: 96, height: 96)
    }
    
}
