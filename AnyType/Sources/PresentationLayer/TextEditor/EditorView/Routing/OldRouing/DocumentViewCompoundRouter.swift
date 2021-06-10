import UIKit
import Combine

/// Compound router which you need to changed
final class DocumentViewCompoundRouter: DocumentViewBaseCompoundRouter {

    // MARK: - Private variables
            
    private weak var viewController: UIViewController?
    
    private var subscription: AnyCancellable?
    
    // MARK: - Init
    
    init(viewController: UIViewController,
         userActionsStream: AnyPublisher<BlocksViews.UserAction, Never>) {
        self.viewController = viewController
        
        super.init()
        
        self.configure(userActionsStream: userActionsStream)
        
        self.subscription = self.outputEventsPublisher
            .sink { [weak self] value in
                self?.handle(value)
            }
    }
    
    // MARK: - Subclassing
    
    override func defaultRouters() -> [DocumentViewBaseRouter] {
        [FileBlocksViewsRouter(), ToolbarsRouter(), PageBlocksViewsRouter()]
    }
    
    override func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? {
        switch action {
        case let .specific(value):
            switch value {
            case .file:
                return router(of: FileBlocksViewsRouter.self)
            case .page:
                return router(of: PageBlocksViewsRouter.self)
            }
        case .toolbars:
            return router(of: ToolbarsRouter.self)
        default:
            return nil
        }
    }
    
}

// MARK: - Private extension

private extension DocumentViewCompoundRouter {
    
    func handle(_ event: DocumentViewRoutingOutputEvent) {
        switch event {
        case let .general(generalEvent):
            handleGeneralEvent(generalEvent)
            
        case let .document(documentEvent):
            handleDocumentEvent(documentEvent)
        }
    }
    
    func handleGeneralEvent(_ event: DocumentViewRoutingOutputEvent.General) {
        switch event {
        case let .child(vc):
            windowHolder?.rootNavigationController.pushViewController(vc, animated: true)
        case let .show(vc):
            viewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func handleDocumentEvent(_ event: DocumentViewRoutingOutputEvent.Document) {
        let generalEvent: DocumentViewRoutingOutputEvent.General = {
            switch event {
            case let .child(id):
                return .child(
                    DocumentEditorBuilder.build(id: id)
                )
            case let .show(id):
                return .show(
                    DocumentEditorBuilder.build(id: id)
                )
            }
        }()
        
        handleGeneralEvent(generalEvent)
    }
    
}
