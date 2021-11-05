import BlocksModels

final class DefaultContextualMenuHandler {
    let handler: BlockActionHandlerProtocol
    let router: EditorRouterProtocol
    
    init(
        handler: BlockActionHandlerProtocol,
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
            handler.duplicate(blockId: info.id)
        case .turnIntoPage:
            handler.handleAction(.turnIntoBlock(.smartblock(.page)), blockId: info.id)
        case .style:
            router.showStyleMenu(information: info)
        case .download,.replace:
            break
        }
    }
    
    
}
