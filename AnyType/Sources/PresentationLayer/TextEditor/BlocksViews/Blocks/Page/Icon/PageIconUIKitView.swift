import Foundation
import UIKit
import Combine
import os
import SwiftUI
import BlocksModels
    

extension PageIconUIKitView {
    struct Layout {
        var emojiViewCornerRadius: CGFloat = 32
        var emojiViewSize = CGSize(width: 64, height: 64)
        var emojiViewBottomPadding: CGFloat = -11
        var addIconButtonHeight: CGFloat = 40
        
        var addIconTitleEdgeInsetsLeft: CGFloat = 4
        var addIconTransformScale: CGFloat = 0.8
    }
    
    enum Style {
        case presentation
        
        func addIconFont() -> UIFont {
            .boldSystemFont(ofSize: 16)
        }
        
        func addIconTitleColor() -> UIColor {
            #colorLiteral(red: 0.6745098039, green: 0.662745098, blue: 0.5882352941, alpha: 1) //#ACA996
        }
        
        func emojiLabelFont() -> UIFont {
            .systemFont(ofSize: 32)
        }
        
        func emojiViewColor() -> UIColor {
            #colorLiteral(red: 0.9529411765, green: 0.9490196078, blue: 0.9254901961, alpha: 1) //#F3F2EC
        }
    }
}


class PageIconUIKitView: UIView {
    
    var layout: Layout = .init()
    var style: Style = .presentation
    
    var contentView: UIView!
    
    var stackView: UIStackView!
    
    var nonEmptyContentView: UIView!
    var imageView: UIImageView!
    var emojiView: UIView!
    var emojiLabel: UILabel!
    
    var addIconButton: UIButton!
    
    weak var viewModel: PageIconViewModel? {
        didSet {
            self.viewModel?.$toViewEmoji.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (value) in
                self?.text = value
            }).store(in: &self.subscriptions)
            self.viewModel?.$toViewImage.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (value) in
                self?.image = value
            }).store(in: &self.subscriptions)
        }
    }
    
    // MARK: Publishers
    func syncViews() {
        self.addIconButton.isHidden = !self.text.isEmpty || self.image != nil
        self.nonEmptyContentView.isHidden = !self.addIconButton.isHidden
        
        self.emojiView.isHidden = self.text.isEmpty || self.image != nil
        self.imageView.isHidden = self.image == nil
    }
    
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
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Setup
    func setup() {
        self.setupUIElements()
        self.addLayout()
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.addSubview(self.contentView)
        
        self.setupStackView()
        
        self.nonEmptyContentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.stackView.addArrangedSubview(self.nonEmptyContentView)
        
        self.setupImageView()
        self.setupEmojiView()
        self.setupAddButton()
    }
    
    func setupImageView() {
        self.imageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            view.layer.cornerRadius = self.layout.emojiViewCornerRadius
            return view
        }()
        
        self.nonEmptyContentView.addSubview(self.imageView)

        let interaction = UIContextMenuInteraction(delegate: self)
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addInteraction(interaction)
    }
    
    func setupEmojiView() {
        
        self.emojiView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = self.style.emojiViewColor()
            view.layer.cornerRadius = self.layout.emojiViewCornerRadius
            return view
        }()
        
        self.emojiLabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self.style.emojiLabelFont()
            label.textAlignment = .center
            return label
        }()
                    
        self.nonEmptyContentView.addSubview(self.emojiView)
        self.emojiView.addSubview(self.emojiLabel)
        
        // Setup action menu
        let interaction = UIContextMenuInteraction(delegate: self)
        self.emojiView.addInteraction(interaction)
    }
    
    func setupStackView() {
        self.stackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        self.contentView.addSubview(self.stackView)
    }
    
    func setupAddButton() {
    
        self.addIconButton = {
            let button = UIButton()
            button.setTitle("Add icon", for: .normal)
            
            // TODO: Need change to right icon, ask designer for it
            button.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/AddBlock"), for: .normal)
            button.imageView?.layer.transform = CATransform3DMakeScale(self.layout.addIconTransformScale,  self.layout.addIconTransformScale, self.layout.addIconTransformScale)
            button.titleEdgeInsets.left = self.layout.addIconTitleEdgeInsetsLeft
            button.titleLabel?.font = self.style.addIconFont()
            button.setTitleColor(self.style.addIconTitleColor(), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.contentHorizontalAlignment = .leading
            button.addTarget(self, action: #selector(addIconButtonPressed), for: .touchUpInside)
            button.sizeToFit()
            return button
        }()
        
        self.stackView.addArrangedSubview(self.addIconButton)
    }

    // MARK: Layout
    func addLayout() {
        if let view = self.contentView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let view = self.stackView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let view = self.imageView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: self.layout.emojiViewBottomPadding),
                view.heightAnchor.constraint(equalToConstant: self.layout.emojiViewSize.height),
                view.widthAnchor.constraint(equalToConstant:  self.layout.emojiViewSize.width)
            ])
        }
        
        if let view = self.emojiView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: self.layout.emojiViewBottomPadding),
                view.heightAnchor.constraint(equalToConstant: self.layout.emojiViewSize.height),
                view.widthAnchor.constraint(equalToConstant:  self.layout.emojiViewSize.width)
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
        
        if let view = self.addIconButton {
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: self.layout.addIconButtonHeight)
            ])
        }
    }
    
    // MARK: Configured
    func configured(model: PageIconViewModel) -> Self {
        self.viewModel = model
        return self
    }
    
    // MARK: Actions
    @objc private func addIconButtonPressed() {
        self.viewModel?.handle(action: .select)
    }
    
}

//TODO: Maybe it is better to add nested object ContextMenu which adopts this protocol and also it shares viewModel with this view

// MARK: - UIContextMenuInteractionDelegate
extension PageIconUIKitView: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,  configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return .init(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            self.makeContextMenu()
        })
    }
    
    func makeContextMenu() -> UIMenu {
        .init(title: "", children: self.viewModel?.actions() ?? [])
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        let targetedView: UIView = self.image != nil ? self.imageView : self.emojiView
        
        parameters.visiblePath = UIBezierPath(roundedRect: targetedView.bounds, cornerRadius: self.layout.emojiViewCornerRadius)
        return .init(view: targetedView, parameters: parameters)
    }
    
}
