import BlocksModels


final class ToggleBlockViewModel: TextBlockViewModel {
    
    override var diffable: AnyHashable {
        let diffable = super.diffable

        return [
            diffable,
            block.isToggled,
            block.childrenIds()
        ]
    }
}
