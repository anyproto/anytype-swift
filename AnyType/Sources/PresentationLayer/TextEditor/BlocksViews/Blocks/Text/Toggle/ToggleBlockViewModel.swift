
import BlocksModels

final class ToggleBlockViewModel: TextBlockViewModel {
    
    override func makeDiffable() -> AnyHashable {
        let diffable = super.makeDiffable()
        return [diffable, getBlock().isToggled, getBlock().childrenIds().isEmpty]
    }
}
