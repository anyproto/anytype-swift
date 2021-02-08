//
//  HomeCollectionViewCell.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

enum HomeStoriesModule {}

fileprivate typealias Namespace = HomeStoriesModule

extension HomeCollectionViewDocumentCellModel {
    struct DashboardPage: Hashable {
        var id: String
        var targetBlockId: String
        static var empty: Self = .init(id: "", targetBlockId: "")
    }
}

extension HomeCollectionViewDocumentCellModel: Hashable {
    static func == (lhs: HomeCollectionViewDocumentCellModel, rhs: HomeCollectionViewDocumentCellModel) -> Bool {
        lhs.page.id == rhs.page.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.page.id)
    }
}

class HomeCollectionViewDocumentCellModel {
    internal init(page: DashboardPage, title: String, image: URL?, emoji: String?, subscriptions: Set<AnyCancellable> = []) {
        self.page = page
        self.title = title
        self.imageURL = image
        self.emoji = emoji
        self.subscriptions = subscriptions
    }
        
    // MARK: - Variables
    /// TODO: Remove published properties and use "plain" values instead.
    let page: DashboardPage
    @Published var title: String
    @Published var emoji: String?
    @Published var imageURL: URL?
    @Published var image: UIImage?
    var imagePublisher: AnyPublisher<UIImage?, Never> = .empty()
    var subscriptions: Set<AnyCancellable> = []
    var userActionSubject: PassthroughSubject<UserActionPayload, Never> = .init()

    // MARK: - Properties
    func imageExists() -> Bool {
        self.imageURL != nil
    }
    func emojiExists() -> Bool {
        self.emoji?.unicodeScalars.first?.properties.isEmoji == true
    }
    
    // MARK: - Providers
    func imageProvider() -> AnyPublisher<UIImage?, Never> {
        guard let imageURL = self.imageURL else {
            return Just(nil).eraseToAnyPublisher()
        }
        return CoreLayer.Network.Image.Loader.init(imageURL).imagePublisher
    }
    
    // MARK: - Configuration
    func configured(titlePublisher: AnyPublisher<String?, Never>) {
        titlePublisher.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.title = value
        }.store(in: &self.subscriptions)
    }
    
    func configured(emojiImagePublisher: AnyPublisher<String?, Never>) {
        emojiImagePublisher.sink { [weak self] (value) in
            self?.emoji = value
        }.store(in: &self.subscriptions)
    }
    
    func configured(imagePublisher: AnyPublisher<String?, Never>) {
        self.imagePublisher = imagePublisher.safelyUnwrapOptionals()
            .flatMap({value in CoreLayer.Network.Image.URLResolver.init().transform(imageId: value).ignoreFailure()})
            .safelyUnwrapOptionals()
            .flatMap({value in CoreLayer.Network.Image.Loader.init(value).imagePublisher})
            .eraseToAnyPublisher()
    }
}

extension HomeCollectionViewDocumentCellModel {
    func configured(userActionSubject: PassthroughSubject<UserActionPayload, Never>) {
        self.userActionSubject = userActionSubject
    }
    
    struct UserActionPayload {
        typealias Model = String
        var model: Model
        var action: HomeCollectionViewDocumentCell.ContextualMenuHandler.UserAction
    }
}

// MARK: Contextual Menu
extension HomeCollectionViewDocumentCell {
    class ContextualMenuHandler: NSObject, UIContextMenuInteractionDelegate {
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            .init(identifier: nil, previewProvider: nil) { (value) -> UIMenu? in
                .init(title: "", children: self.getContextualMenu())
            }
        }
        
        private var userActionSubject: PassthroughSubject<UserAction, Never> = .init()
        var userActionPublisher: AnyPublisher<UserAction, Never> = .empty()
        
        private var actionMenuItems: [ActionMenuItem] = []
        
        override init() {
            self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
            super.init()
            self.setupActionMenuItems()
        }
    }
}

extension HomeCollectionViewDocumentCell.ContextualMenuHandler {
    struct ActionMenuItem {
        var action: UserAction
        var title: String
        var imageName: String
    }
    
    struct UserActionPayload {
        typealias Model = String
        var model: Model
        var action: UserAction
    }
    
    enum UserAction: String, CaseIterable {
        case remove = "Remove"
    }
    
    func handle(action: UserAction) {
        switch action {
        case .remove: self.remove()
        }
    }
    
    func remove() {
        /// send to outerworld
        self.userActionSubject.send(.remove)
    }
    
    /// Convert to UIAction
    func actions() -> [UIAction] {
        self.actionMenuItems.map(self.action(with:))
    }
    
    func action(with item: ActionMenuItem) -> UIAction {
        .init(title: item.title, image: UIImage(named: item.imageName)) { action in
            self.handle(action: item.action)
        }
    }
    
    func getContextualMenu() -> [UIAction] {
        self.actions()
    }
    
    func setupActionMenuItems() {
        self.actionMenuItems = [
            .init(action: .remove, title: UserAction.remove.rawValue, imageName: "Emoji/ContextMenu/remove")
        ]
    }
}

final class HomeCollectionViewDocumentCell: UICollectionViewCell {
    static let reuseIdentifer = "homeCollectionViewDocumentCellReuseIdentifier"
    
    @Environment(\.developerOptions) var developerOptions
    
    let titleLabel: UILabel = .init()
    let emoji: UILabel = .init()
    let imageView: UIImageView = .init()
    let roundView: UIView = .init()
    
    private var layout: Layout = .init()
    private var style: Style = .presentation
    private var contextualMenuHandler: ContextualMenuHandler = .init()
    
    private var storedPage: HomeCollectionViewDocumentCellModel.DashboardPage = .empty
    
    var titleSubscription: AnyCancellable?
    var emojiSubscription: AnyCancellable?
    var imageSubscription: AnyCancellable?
    var imageLoadingSubscription: AnyCancellable?
    var userActionSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invalidateSubscriptions() {
        self.titleSubscription = nil
        self.emojiSubscription = nil
        self.imageSubscription = nil
        self.imageLoadingSubscription = nil
        self.userActionSubscription = nil
    }
    
    func invalidateData() {
        self.titleLabel.text = nil
        self.imageView.image = nil
        self.emoji.text = nil
    }
    
    func syncViews() {
        let imageExists = self.imageView.image != nil
        let emojiExists = self.emoji.text?.isEmpty == false
        self.emoji.isHidden = imageExists || !emojiExists
    }
    
    func updateWithModel(viewModel: HomeCollectionViewDocumentCellModel) {
        if viewModel.page != self.storedPage {
            self.invalidateSubscriptions()
            self.invalidateData()
        }
        self.storedPage = viewModel.page
        
        /// Subsrcibe on viewModel updates
        self.titleLabel.text = viewModel.title
        self.emoji.text = viewModel.emoji
        self.syncViews()
        self.titleSubscription = viewModel.$title.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.titleLabel.text = value
        }
        self.emojiSubscription = viewModel.$emoji.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.emoji.text = value
            self?.syncViews()
        }
        self.imageLoadingSubscription = viewModel.imagePublisher.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.imageView.image = value
            self?.syncViews()
        }
        self.userActionSubscription = self.contextualMenuHandler.userActionPublisher.sink{ [weak viewModel] (value) in
            if let id = viewModel?.page.id {
                viewModel?.userActionSubject.send(.init(model: id, action: value))
            }
        }
    }
}

extension HomeCollectionViewDocumentCell {
    struct Layout {
        let cornerRadius: CGFloat = 8.0
        let offset: CGFloat = 16.0
        let roundIconSize: CGSize = .init(width: 48, height: 48)
        var roundIconCornerRadius: CGFloat { self.roundIconSize.width / 2 }
    }
    
    enum Style {
        case presentation
        var backgroundColor: UIColor? {
            switch self {
            case .presentation: return .white
            }
        }
        var iconBackgroundColor: UIColor? {
            switch self {
            case .presentation: return UIColor(named: "TextEditor/Colors/Background")
            }
        }
    }
}

private extension HomeCollectionViewDocumentCell {
    func configureViews() {
        self.roundView.backgroundColor = self.style.iconBackgroundColor
        self.roundView.layer.cornerRadius = self.layout.roundIconCornerRadius
        
        self.roundView.clipsToBounds = true
        
        self.imageView.contentMode = .scaleAspectFit
        
        self.emoji.textAlignment = .center
    }
        
    func configureCell() {
        self.layer.cornerRadius = self.layout.cornerRadius
        self.backgroundColor = self.style.backgroundColor
        
        if self.developerOptions.current.workflow.dashboard.cellsHaveActionsOnLongTap {
            let interaction: UIContextMenuInteraction = .init(delegate: self.contextualMenuHandler)
            
            self.addInteraction(interaction)
        }
    }
    
    func configureLayout() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.roundView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.emoji.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.roundView)
        self.roundView.addSubview(self.imageView)
        self.roundView.addSubview(self.emoji)
        
        let offset = self.layout.offset
        let size = self.layout.roundIconSize
        
        if let superview = self.roundView.superview {
            let view = self.roundView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: offset),
                view.heightAnchor.constraint(equalToConstant: size.height),
                view.widthAnchor.constraint(equalToConstant: size.width)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.imageView.superview {
            let view = self.imageView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.emoji.superview {
            let view = self.emoji
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.titleLabel.superview {
            let view = self.titleLabel
            let topView = self.imageView
            let constraints = [
                view.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: offset),
                view.leftAnchor.constraint(equalTo: topView.leftAnchor),
                view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -offset),
                view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func configure() {
        self.configureCell()
        self.configureViews()
        self.configureLayout()
    }
}
