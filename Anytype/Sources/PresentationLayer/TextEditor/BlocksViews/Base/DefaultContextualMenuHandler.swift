import BlocksModels

final class DefaultContextualMenuHandler {
    let handler: EditorActionHandlerProtocol
    let router: EditorRouterProtocol
    
    init(
        handler: EditorActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.handler = handler
        self.router = router
    }
    
    func handle(action: ContextualMenuAction, info: BlockInformation) {
        switch action {
        case .addBlockBelow:
            handler.handleAction(.addBlock(.text(.text)), info: info)
        case .delete:
            handler.handleAction(.delete, info: info)
        case .duplicate:
            handler.handleAction(.duplicate, info: info)
        case .turnIntoPage:
            handler.handleAction(.turnIntoBlock(.objects(.page)), info: info)
        case .style:
            router.showStyleMenu(information: info)
            
        case .moveTo, .color, .backgroundColor:
            break
        case .download,.replace, .addCaption, .rename:
            break
        }
    }
    
    
}
