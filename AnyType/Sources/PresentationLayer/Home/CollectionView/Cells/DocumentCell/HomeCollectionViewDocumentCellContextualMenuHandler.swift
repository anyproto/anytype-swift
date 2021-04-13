import Foundation
import SwiftUI
import Combine

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
