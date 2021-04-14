import BlocksModels

extension HomeCollectionViewModel {
    enum UserEvent {
        struct ContextualMenuAction {
            typealias Model = BlockId
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            var model: Model
            var action: Action
        }
        case contextualMenu(ContextualMenuAction)
    }
}
