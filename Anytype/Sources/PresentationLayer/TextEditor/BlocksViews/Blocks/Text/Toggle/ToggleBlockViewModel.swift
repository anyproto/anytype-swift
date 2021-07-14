import BlocksModels


final class ToggleBlockViewModel: TextBlockViewModel {
    
    /// Using structs instead of classes will allow us to remove this property
    private let storedToggled: Bool
    
    override init(_ block: BlockActiveRecordProtocol,
                  delegate: BlockDelegate?,
                  actionHandler: EditorActionHandlerProtocol,
                  router: EditorRouterProtocol) {
        storedToggled = block.isToggled
        super.init(
            block,
            delegate: delegate,
            actionHandler: actionHandler,
            router: router
        )
    }
    
    override var diffable: AnyHashable {
        let diffable = super.diffable

        return [
            diffable,
            storedToggled,
            block.childrenIds()
        ]
    }
}
