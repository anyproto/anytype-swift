//
//  PageBlocksViews+IconEmoji.swift
//  AnyType
//
//  Created by Valetine Eyiubolu on 04.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os
import SwiftUI

private extension Logging.Categories {
    static let pageBlocksViewsIconEmoji: Self = "TextEditor.BlocksViews.PageBlocksViews.IconEmoji"
}

// MARK: - ViewModel
extension PageBlocksViews.IconEmoji {
   
    class BlockViewModel: PageBlocksViews.Base.BlockViewModel {
     
        private var subscriptions: Set<AnyCancellable> = []
    
        @Published var toViewEmoji: String = ""
        @Published var fromUserActionSubject: PassthroughSubject<String, Never> = .init()

        var toModelEmojiSubject: PassthroughSubject<String, Never> = .init()
        
        public var actionMenuItems: [ActionMenuItem] = []
   
        // MARK: - Initialization
        override init(_ block: BlocksViews.Base.ViewModel.BlockModel) {
            super.init(block)
            self.setup(block: block)
        }

        // MARK: - Setup
        private func setupSubscribers() {
            //TODO: Better to listen wholeDetailsPublisher when details is updating
            self.fromUserActionSubject.sink { [weak self] (value) in
                self?.toModelEmojiSubject.send(value)
                self?.toViewEmoji = value
            }.store(in: &subscriptions)
        }

        private func setup(block: BlocksViews.Base.ViewModel.BlockModel) {
            self.setupSubscribers()
            self.setupActionMenuItems()
        }
        
        // MARK: Subclassing / Events
        override func onIncoming(event: PageBlocksViews.Base.Events) {
            switch event {
            case .pageDetailsViewModelDidSet:
                
                self.pageDetailsViewModel?.wholeDetailsPublisher.map(\.iconEmoji).sink(receiveValue: { [weak self] (value) in
                    value.flatMap({self?.toViewEmoji = $0.text})
                }).store(in: &self.subscriptions)
                
                self.toModelEmojiSubject.notableError().flatMap({ [weak self] value in
                    self?.pageDetailsViewModel?.update(details: .iconEmoji(.init(text: value))) ?? .empty()
                }).sink(receiveCompletion: { (value) in
                    switch value {
                    case .finished: return
                    case let .failure(error):
                        let logger = Logging.createLogger(category: .pageBlocksViewsIconEmoji)
                        os_log(.debug, log: logger, "PageBlocksViews emoji setDetails error has occured. %@", String(describing: error))
                    }
                }, receiveValue: {}).store(in: &self.subscriptions)
            }
        }

        // MARK: Subclassing / Views
        override func makeUIView() -> UIView {
            UIKitView.init().configured(model: self)
        }
        
    }
}

// MARK: - ActionMenu handler
extension PageBlocksViews.IconEmoji.BlockViewModel {
    
    struct ActionMenuItem {
        var action: UserAction
        var title: String
        var imageName: String
    }
    
    enum UserAction: String, CaseIterable {
        case select = "Choose emoji"
        case random = "Pick emoji randomly"
        case upload = "Upload photo"
        case remove = "Remove"
    }
    
    func handle(action: UserAction) {
        switch action {
        case .select:
            self.select()
        case .random:
            self.random()
        case .remove:
            self.remove()
        default:
            let logger = Logging.createLogger(category: .pageBlocksViewsIconEmoji)
            os_log(.debug, log: logger, "We handle only actions above. Action %@ isn't handled", String(describing: action))
        }
    }
    
    /// Convert to UIAction
    func actions() -> [UIAction] {
        self.actionMenuItems.map(self.action(with:))
    }
        
    func action(with item: ActionMenuItem) -> UIAction {
        UIAction(title: item.title, image: UIImage(named: item.imageName)) { action in
            self.handle(action: item.action)
        }
    }
    
    func setupActionMenuItems() {
        actionMenuItems = [
            .init(action: .select, title: UserAction.select.rawValue, imageName: "Emoji/ContextMenu/choose"),
            .init(action: .random, title: UserAction.random.rawValue, imageName: "Emoji/ContextMenu/random"),
            .init(action: .upload, title: UserAction.upload.rawValue, imageName: "Emoji/ContextMenu/upload"),
            .init(action: .remove, title: UserAction.remove.rawValue, imageName: "Emoji/ContextMenu/remove")
        ]
    }
    
}

// MARK: - ActionMenu Actions
extension PageBlocksViews.IconEmoji.BlockViewModel {
   
    func select() {
        let model = EmojiPicker.ViewModel()
               
        model.$selectedEmoji.safelyUnwrapOptionals().sink { [weak self] (emoji) in
            self?.fromUserActionSubject.send(emoji.unicode)
        }.store(in: &subscriptions)
           
        self.send(userAction: .specific(.page(.emoji(.shouldShowEmojiPicker(model)))))
    }
           
    func random() {
        let emoji = EmojiPicker.Manager().random()
        self.fromUserActionSubject.send(emoji.unicode)
    }
        
    func remove() {
        let emoji = EmojiPicker.Manager.Emoji.empty()
        self.fromUserActionSubject.send(emoji.unicode)
    }
          
}

// MARK: Layout
private extension PageBlocksViews.IconEmoji.UIKitView {
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


// MARK: - UIView
private extension PageBlocksViews.IconEmoji {
    class UIKitView: UIView {
        
        var layout: Layout = .init()
        var style: Style = .presentation
    
        var contentView: UIView!
        
        var stackView: UIStackView!
        
        var parentEmojiView: UIView!
        var emojiView: UIView!
        var emojLabel: UILabel!
        
        var addIconButton: UIButton!
    
        var viewModel: BlockViewModel? {
            didSet {
                self.viewModel?.$toViewEmoji.receive(on: RunLoop.main).sink(receiveValue: { (value) in
                    self.text = value
                }).store(in: &subscriptions)
            }
        }
        
        // MARK: Publishers
        private var subscriptions: Set<AnyCancellable> = []
        private var text: String = "" {
            didSet {
                self.emojLabel.text = text
                self.addIconButton.isHidden = !text.isEmpty
                self.parentEmojiView.isHidden = text.isEmpty
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
            
            self.addSubview(contentView)
            
            self.setupStackView()
            self.setupEmojiView()
            self.setupAddButton()
        }
        
        func setupEmojiView() {
            
            self.parentEmojiView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.emojiView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = self.style.emojiViewColor()
                view.layer.cornerRadius = self.layout.emojiViewCornerRadius
                return view
            }()
            
            self.emojLabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = self.style.emojiLabelFont()
                label.textAlignment = .center
                return label
            }()
            
            self.stackView.addArrangedSubview(parentEmojiView)
            
            self.parentEmojiView.addSubview(emojiView)
            self.emojiView.addSubview(emojLabel)
            
            // Setup action menu
            let interaction = UIContextMenuInteraction(delegate: self)
            emojiView.addInteraction(interaction)
        }
        
        func setupStackView() {
            self.stackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.translatesAutoresizingMaskIntoConstraints = false
                return stackView
            }()
            
            self.contentView.addSubview(stackView)
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
            
            self.stackView.addArrangedSubview(addIconButton)
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
            
            if let view = self.emojiView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: self.layout.emojiViewBottomPadding),
                    view.heightAnchor.constraint(equalToConstant: self.layout.emojiViewSize.height),
                    view.widthAnchor.constraint(equalToConstant:  self.layout.emojiViewSize.width)
                ])
            }
            
            if let view = self.emojLabel, let superview = view.superview {
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
        func configured(model: BlockViewModel) -> Self {
            self.viewModel = model
            return self
        }
        
        // MARK: Actions
        @objc private func addIconButtonPressed() {
            self.viewModel?.handle(action: .select)
        }
        
    }

}

//TODO: Maybe it is better to add nested object ContextMenu which adopts this protocol and also it shares viewModel with this view

// MARK: - UIContextMenuInteractionDelegate
extension PageBlocksViews.IconEmoji.UIKitView: UIContextMenuInteractionDelegate {
    
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
        parameters.visiblePath = UIBezierPath(roundedRect: emojiView.bounds, cornerRadius: self.layout.emojiViewCornerRadius)
        return UITargetedPreview(view: self.emojiView, parameters: parameters)
    }
    
}
