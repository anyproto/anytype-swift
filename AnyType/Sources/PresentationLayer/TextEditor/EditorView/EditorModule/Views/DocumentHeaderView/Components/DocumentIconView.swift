import Foundation
import UIKit
import Combine
import os
import SwiftUI
import BlocksModels

final class DocumentIconView: UIView {
    
    private let style: Style = .presentation
    
    var imageView: UIImageView!
    
    var emojiView: UIView!
    var emojiLabel: UILabel!
    
    private var subscriptions: Set<AnyCancellable> = []
    private var text: String = "" {
        didSet {
            self.emojiLabel.text = self.text
            self.syncViews()
        }
    }
    
    private var image: UIImage? {
        didSet {
            self.imageView.image = self.image
            self.syncViews()
        }
    }
    
    weak var viewModel: DocumentIconViewModel? {
        didSet {
            self.viewModel?.$toViewEmoji.reciveOnMain()
                .sink { [weak self] text in
                    self?.text = text
                }
                .store(in: &self.subscriptions)
            self.viewModel?.$toViewImage.reciveOnMain()
                .sink { [weak self] image in
                    self?.image = image
                }
                .store(in: &self.subscriptions)
        }
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }

}

// MARK: - ConfigurableView

extension DocumentIconView: ConfigurableView {
    
    func configure(model: DocumentIconViewModel) {
        self.viewModel = model
    }
    
}

// MARK: - Private extension

private extension DocumentIconView {
    
    // MARK: Setup
    func setup() {
        self.setupUIElements()
        self.addLayout()
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
    
        setupImageView()
        setupEmojiView()
    }
    
    func setupImageView() {
        self.imageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            view.layer.cornerRadius = Constants.EmojiView.cornerRadius
            return view
        }()
        
        addSubview(imageView)

        let interaction = UIContextMenuInteraction(delegate: self)
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addInteraction(interaction)
    }
    
    func setupEmojiView() {
        self.emojiView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = self.style.emojiViewColor()
            view.layer.cornerRadius = Constants.EmojiView.cornerRadius
            return view
        }()
        
        self.emojiLabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self.style.emojiLabelFont()
            label.textAlignment = .center
            return label
        }()
                    
        addSubview(self.emojiView)
        self.emojiView.addSubview(self.emojiLabel)
        
        // Setup action menu
        let interaction = UIContextMenuInteraction(delegate: self)
        self.emojiView.addInteraction(interaction)
    }

    // MARK: Layout
    func addLayout() {
        if let view = self.imageView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(
                    equalTo: superview.bottomAnchor,
                    constant: Constants.EmojiView.bottomPadding
                ),
                view.heightAnchor.constraint(equalToConstant: Constants.EmojiView.size.height),
                view.widthAnchor.constraint(equalToConstant:  Constants.EmojiView.size.width)
            ])
        }
        
        if let view = self.emojiView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: Constants.EmojiView.bottomPadding),
                view.heightAnchor.constraint(equalToConstant: Constants.EmojiView.size.height),
                view.widthAnchor.constraint(equalToConstant:  Constants.EmojiView.size.width)
            ])
        }
        
        if let view = self.emojiLabel, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    // MARK: Publishers
    
    func syncViews() {
        self.emojiView.isHidden = self.text.isEmpty || !self.image.isNil
        self.imageView.isHidden = self.image.isNil
    }
    
}

// MARK: - Constants

private extension DocumentIconView {
    
    enum Constants {
        enum EmojiView {
            static let cornerRadius: CGFloat = 32
            static let size = CGSize(width: 64, height: 64)
            static let bottomPadding: CGFloat = -11
        }
    }
    
    enum Style {
        case presentation
        
        func emojiLabelFont() -> UIFont {
            .systemFont(ofSize: 32)
        }
        
        func emojiViewColor() -> UIColor {
            #colorLiteral(red: 0.9529411765, green: 0.9490196078, blue: 0.9254901961, alpha: 1) //#F3F2EC
        }
    }
    
}

//TODO: Maybe it is better to add nested object ContextMenu which adopts this protocol and also it shares viewModel with this view

// MARK: - UIContextMenuInteractionDelegate

extension DocumentIconView: UIContextMenuInteractionDelegate {
    
    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { suggestedActions in
                UIMenu(
                    title: "",
                    children: self.viewModel?.actions() ?? []
                )
            }
        )
    }
    
    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        let targetedView: UIView = !self.image.isNil ? self.imageView : self.emojiView
        
        parameters.visiblePath = UIBezierPath(
            roundedRect: targetedView.bounds,
            cornerRadius: Constants.EmojiView.cornerRadius
        )
        return UITargetedPreview(view: targetedView, parameters: parameters)
    }
    
}
