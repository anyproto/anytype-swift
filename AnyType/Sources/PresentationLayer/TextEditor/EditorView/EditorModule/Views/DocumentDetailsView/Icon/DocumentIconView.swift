import Foundation
import UIKit
import Combine

final class DocumentIconView: UIView {
    
    // MARK: - Private properties
    
    private let iconEmojiView: IconEmojiView = IconEmojiView()
    
    private weak var viewModel: DocumentIconViewModelNew?
//    private weak var viewModel: DocumentIconViewModel? // Will be removed later
    
    private var subscriptions: Set<AnyCancellable> = []
    
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
    
    func configure(model: DocumentIconViewModelNew) {
        viewModel = model
        viewModel?.$iconEmoji.reciveOnMain()
            .sink { [weak self] newEmoji in
                self?.iconEmojiView.configure(model: newEmoji)
            }
            .store(in: &self.subscriptions)
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
        layoutUsing.stack {
            $0.hStack(
                iconEmojiView,
                $0.hGap()
            )
        }
        
        iconEmojiView.layoutUsing.anchors {
            $0.size(Constants.EmojiView.size)
        }
    }
    
}

//TODO: Maybe it is better to add nested object ContextMenu which adopts this protocol and also it shares viewModel with this view

// MARK: - UIContextMenuInteractionDelegate

extension DocumentIconView: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let actions = viewModel?.contextMenuActions else { return nil }
        
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
