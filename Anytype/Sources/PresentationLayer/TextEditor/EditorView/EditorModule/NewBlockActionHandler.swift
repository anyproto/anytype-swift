import BlocksModels

protocol NewBlockActionHandler: AnyObject {
    func handleAction(_ action: BlockActionHandler.ActionType, model: BlockModelProtocol)
    func handleActionForFirstResponder(_ action: BlockActionHandler.ActionType)
    func handleActionWithoutCompletion(_ action: BlockActionHandler.ActionType, model: BlockModelProtocol)
}
