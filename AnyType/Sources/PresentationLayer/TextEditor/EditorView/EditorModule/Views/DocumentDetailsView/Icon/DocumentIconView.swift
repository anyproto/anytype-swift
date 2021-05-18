import Foundation
import UIKit
import Combine

final class DocumentIconView: UIView {
    
    var onUserAction: ((DocumentIconViewUserAction) -> Void)?
    
    // MARK: - Private properties
    
    private let iconEmojiView: IconEmojiView = IconEmojiView()
        
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

extension DocumentIconView: ConfigurableView {
    
    func configure(model: String) {
        iconEmojiView.configure(model: model)
        iconEmojiView.layoutUsing.anchors {
            $0.size(Constants.EmojiView.size)
        }
    }
    
}

// MARK: - Private extension

private extension DocumentIconView {
    
    func setUpView() {
        configureIconEmojiView()
        
        setUpLayout()
    }
    
    func configureIconEmojiView() {
        // Setup action menu
        let interaction = UIContextMenuInteraction(delegate: self)
        iconEmojiView.addInteraction(interaction)
        
        iconEmojiView.layer.cornerRadius = Constants.EmojiView.cornerRadius
    }
    
    func setUpLayout() {
        addSubview(iconEmojiView)
        iconEmojiView.pinAllEdges(to: self)
    }
    
}

// MARK: - UIContextMenuInteractionDelegate

extension DocumentIconView: UIContextMenuInteractionDelegate {

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
        let targetedView: UIView = iconEmojiView

        parameters.visiblePath = UIBezierPath(
            roundedRect: targetedView.bounds,
            cornerRadius: targetedView.layer.cornerRadius
        )

        return UITargetedPreview(view: targetedView, parameters: parameters)
    }

}

// MARK: - Constants

private extension DocumentIconView {
    
    enum Constants {
        enum EmojiView {
            static let cornerRadius: CGFloat = 20
            static let size = CGSize(width: 96, height: 96)
        }
    }
    
}
