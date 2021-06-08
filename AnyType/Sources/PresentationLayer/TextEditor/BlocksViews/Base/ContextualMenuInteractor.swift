import Foundation
import UIKit
import Combine

class ContextualMenuInteractor: NSObject, UIContextMenuInteractionDelegate {
    // MARK: Conversion BlocksViews.ContextualMenu.MenuAction <-> UIAction.Identifier
    enum IdentifierConverter {
        static func action(for menuAction: BlocksViews.ContextualMenu.MenuAction) -> UIAction.Identifier? {
            menuAction.identifier.flatMap({UIAction.Identifier.init($0)})
        }
        static func menuAction(for identifier: UIAction.Identifier?) -> BlocksViews.ContextualMenu.MenuAction.Action? {
            identifier.flatMap({BlocksViews.ContextualMenu.MenuAction.Resources.IdentifierBuilder.action(for: $0.rawValue)})
        }
    }
    
    // MARK: Provider
    /// Actually, Self
    weak var provider: BaseBlockViewModel?
    
    // MARK: Subject ( Subsribe on it ).
    var actionSubject: PassthroughSubject<BlocksViews.ContextualMenu.MenuAction.Action, Never> = .init()
    
    // MARK: Conversion BlocksViews.ContextualMenu and BlocksViews.ContextualMenu.MenuAction
    static func menu(from: BlocksViews.ContextualMenu?) -> UIMenu? {
        from.flatMap{ .init(title: $0.title, image: nil, identifier: nil, options: .init(), children: []) }
    }
    
    static func action(from action: BlocksViews.ContextualMenu.MenuAction, handler: @escaping (UIAction) -> ()) -> UIAction {
        .init(title: action.payload.title, image: action.payload.currentImage, identifier: IdentifierConverter.action(for: action), discoverabilityTitle: nil, attributes: [], state: .off, handler: handler)
    }
    
    // MARK: Delegate methods

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(identifier: "" as NSCopying, previewProvider: nil) { [weak self] (value) -> UIMenu? in
            let menu = self?.provider?.makeContextualMenu()
            return menu.flatMap {
                .init(title: $0.title, image: nil, identifier: nil, options: .init(), children: $0.children.map { [weak self] child in
                    ContextualMenuInteractor.action(from: child) { [weak self] (action) in
                        IdentifierConverter.menuAction(for: action.identifier).flatMap({self?.actionSubject.send($0)})
                    }
                })
            }
        }
    }
}
