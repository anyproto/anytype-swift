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
    
    func handle(action: ContextualMenu, info: BlockInformation) {
        switch action {
        case .addBlockBelow:
            handler.handleAction(.addBlock(.text(.text)), blockId: info.id)
        case .delete:
            handler.handleAction(.delete, blockId: info.id)
        case .duplicate:
            handler.handleAction(.duplicate, blockId: info.id)
        case .turnIntoPage:
            handler.handleAction(.turnIntoBlock(.objects(.page)), blockId: info.id)
        case .style:
            router.showStyleMenu(information: info)
        case .download,.replace:
            break
        }
    }
    
    
}
